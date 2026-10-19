// test/ump_integration_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twenty48/core/services/ad_service.dart';
import 'package:twenty48/core/services/ump_consent_service.dart';
import 'package:twenty48/features/consent/consent_gate.dart';
import 'package:twenty48/features/consent/consent_service.dart';
import 'package:twenty48/features/settings/providers/theme_provider.dart';
import 'package:twenty48/features/settings/ui/ads_setting_tile.dart';

class FakeUmpConsentService extends UmpConsentService {
  bool gatherConsentResult;
  bool privacyOptionsRequiredResult;
  bool showPrivacyOptionsCalled = false;
  int gatherConsentCallCount = 0;

  FakeUmpConsentService({
    this.gatherConsentResult = true,
    this.privacyOptionsRequiredResult = false,
  }) : super(timeoutDuration: const Duration(milliseconds: 50));

  @override
  Future<bool> gatherConsent() async {
    gatherConsentCallCount++;
    return gatherConsentResult;
  }

  @override
  Future<bool> privacyOptionsRequired() async {
    return privacyOptionsRequiredResult;
  }

  @override
  Future<void> showPrivacyOptions() async {
    showPrivacyOptionsCalled = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AdService.instance.disableAds();
  });

  testWidgets('ads init not called when user declined', (tester) async {
    SharedPreferences.setMockInitialValues({
      'consentVersion': 1,
      'consentDecision': 'decline',
    });
    final fakeUmp = FakeUmpConsentService(gatherConsentResult: true);

    await tester.pumpWidget(
      MaterialApp(
        home: ConsentGate(
          consentService: ConsentService(),
          umpConsentService: fakeUmp,
          child: const Text('Game Screen'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(fakeUmp.gatherConsentCallCount, 0);
    expect(AdService.instance.adsEnabled, isFalse);
  });

  testWidgets('ads init not called when gatherConsent returns false', (tester) async {
    SharedPreferences.setMockInitialValues({
      'consentVersion': 1,
      'consentDecision': 'agree',
    });
    final fakeUmp = FakeUmpConsentService(gatherConsentResult: false);

    await tester.pumpWidget(
      MaterialApp(
        home: ConsentGate(
          consentService: ConsentService(),
          umpConsentService: fakeUmp,
          child: const Text('Game Screen'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(fakeUmp.gatherConsentCallCount, 1);
    expect(AdService.instance.adsEnabled, isFalse);
  });

  testWidgets('ads init called once when all three are true', (tester) async {
    SharedPreferences.setMockInitialValues({
      'consentVersion': 1,
      'consentDecision': 'agree',
    });
    final fakeUmp = FakeUmpConsentService(gatherConsentResult: true);

    await tester.pumpWidget(
      MaterialApp(
        home: ConsentGate(
          consentService: ConsentService(),
          umpConsentService: fakeUmp,
          child: const Text('Game Screen'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(fakeUmp.gatherConsentCallCount, 1);
    expect(AdService.instance.adsEnabled, isTrue);
  });

  testWidgets('Privacy choices row hidden when not required and shown when required', (tester) async {
    SharedPreferences.setMockInitialValues({});
    
    // Not required
    final fakeUmpNotReq = FakeUmpConsentService(privacyOptionsRequiredResult: false);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: AdsSettingTile(
              key: const Key('ads_tile_not_req'),
              consentService: ConsentService(),
              umpConsentService: fakeUmpNotReq,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Privacy choices'), findsNothing);

    // Required
    SharedPreferences.setMockInitialValues({});
    final fakeUmpReq = FakeUmpConsentService(privacyOptionsRequiredResult: true);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: AdsSettingTile(
              key: const Key('ads_tile_req'),
              consentService: ConsentService(),
              umpConsentService: fakeUmpReq,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Privacy choices'), findsOneWidget);
  });

  test('gatherConsent never throws on simulated error or timeout', () async {
    final service = UmpConsentService(timeoutDuration: const Duration(milliseconds: 10));
    final result = await service.gatherConsent();
    expect(result, isA<bool>());
    expect(result, isFalse);
  });
}
