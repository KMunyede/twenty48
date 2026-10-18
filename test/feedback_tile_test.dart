// ignore_for_file: depend_on_referenced_packages

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:twenty48/features/consent/consent_link_style.dart';
import 'package:twenty48/features/settings/providers/theme_provider.dart';
import 'package:twenty48/features/settings/ui/feedback_tile.dart';

class MockUrlLauncher extends UrlLauncherPlatform {
  bool launchResult = false;
  String? lastLaunchedUrl;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    lastLaunchedUrl = url;
    return launchResult;
  }
}

double contrastRatio(Color c1, Color c2) {
  final l1 = c1.computeLuminance();
  final l2 = c2.computeLuminance();
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeedbackTile Tests', () {
    late MockUrlLauncher mockUrlLauncher;

    setUp(() {
      mockUrlLauncher = MockUrlLauncher();
      UrlLauncherPlatform.instance = mockUrlLauncher;
    });

    testWidgets('renders label "Send feedback" and subtitle "Tell us what to improve"', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MaterialApp(
            home: Scaffold(
              body: FeedbackTile(),
            ),
          ),
        ),
      );

      expect(find.text('Send feedback'), findsOneWidget);
      expect(find.text('Tell us what to improve'), findsOneWidget);
      expect(find.byIcon(Icons.mail), findsOneWidget);
    });

    testWidgets('tapping with mocked url_launcher returning false shows SnackBar', (WidgetTester tester) async {
      mockUrlLauncher.launchResult = false;

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MaterialApp(
            home: Scaffold(
              body: FeedbackTile(),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Send feedback'));
      await tester.pumpAndSettle();

      expect(
        find.text('No email app found. Write to support@hilmost.net'),
        findsOneWidget,
      );
      expect(
        mockUrlLauncher.lastLaunchedUrl,
        contains('mailto:support@hilmost.net'),
      );
    });
  });

  group('Consent Link Contrast Ratio Tests', () {
    test('link color meets 4.5:1 contrast ratio against dark and light backgrounds', () {
      // Dark background (e.g. Rhino Grey 0xFF2E3338)
      const darkBg = Color(0xFF2E3338);
      final darkRatio = contrastRatio(kConsentLinkDarkBgColor, darkBg);
      expect(darkRatio, greaterThanOrEqualTo(4.5));

      // Light background (e.g. Rare Indigo 0xFFC3C7E0)
      const lightBg = Color(0xFFC3C7E0);
      final lightRatio = contrastRatio(kConsentLinkLightBgColor, lightBg);
      expect(lightRatio, greaterThanOrEqualTo(4.5));
    });
  });
}
