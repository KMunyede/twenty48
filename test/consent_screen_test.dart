// test/consent_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twenty48/core/services/ad_service.dart';
import 'package:twenty48/features/consent/consent_gate.dart';
import 'package:twenty48/features/consent/consent_texts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AdService.instance.disableAds();
  });

  group('Consent Gate & Screen Widget Tests', () {
    testWidgets('both buttons are present on consent screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConsentGate(
            child: Text('Game Screen Child'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(kConsentAgreeButtonLabel), findsOneWidget);
      expect(find.text(kConsentDeclineButtonLabel), findsOneWidget);
      expect(find.text(kConsentTitle), findsOneWidget);
      expect(find.text(kConsentBody), findsOneWidget);
      expect(find.text(kConsentPrivacyLinkLabel), findsOneWidget);
    });

    testWidgets('tapping "No thanks" reveals the child and never calls enableAds', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConsentGate(
            child: Text('Game Screen Child'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Game Screen Child'), findsNothing);
      expect(AdService.instance.adsEnabled, isFalse);

      await tester.tap(find.text(kConsentDeclineButtonLabel));
      await tester.pumpAndSettle();

      expect(find.text('Game Screen Child'), findsOneWidget);
      expect(AdService.instance.adsEnabled, isFalse);
    });

    testWidgets('the failure path of the link does not throw', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConsentGate(
            child: Text('Game Screen Child'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final linkFinder = find.text(kConsentPrivacyLinkLabel);
      expect(linkFinder, findsOneWidget);

      await tester.tap(linkFinder);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
