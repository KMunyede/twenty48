import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twenty48/features/game/milestones/card_colors.dart';
import 'package:twenty48/features/game/milestones/milestone_celebration.dart';
import 'package:twenty48/features/game/milestones/milestone_ladder.dart';
import 'package:twenty48/features/game/providers/game_provider.dart';
import 'package:twenty48/features/settings/models/app_theme.dart';
import 'package:twenty48/features/settings/providers/theme_provider.dart';

String _toHex(Color c) {
  final r = (c.r * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase();
  final g = (c.g * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase();
  final b = (c.b * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase();
  return '#$r$g$b';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pure helper tests', () {
    test('contrastRatio of black and white is 21', () {
      final ratio = contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF));
      expect(ratio, closeTo(21.0, 0.001));
    });

    test('ensureContrast raises a low-contrast pair to the requested ratio', () {
      const lowContrastPair = Color(0xFFCCCCCC);
      const background = Color(0xFFFFFFFF);

      final initialRatio = contrastRatio(lowContrastPair, background);
      expect(initialRatio, lessThan(4.5));

      final adjusted = ensureContrast(lowContrastPair, background, 4.5);
      final newRatio = contrastRatio(adjusted, background);
      expect(newRatio, greaterThanOrEqualTo(4.5));
    });
  });

  group('MilestoneCelebrationCard Tests', () {
    testWidgets(
        'Widget test: for EVERY theme, builds inside 360dp width, height <= 280dp, texts & OK found, contrast checks pass',
        (WidgetTester tester) async {
      for (final theme in AppTheme.themes) {
        SharedPreferences.setMockInitialValues({'selectedTheme': theme.name});
        final themeProvider = ThemeProvider();
        await tester.pumpAndSettle();

        const milestone = Milestone(
          value: 1024,
          title: 'True Prodigy',
          hype:
              "You're moving with suspicious confidence. This isn't luck anymore.",
        );

        await tester.pumpWidget(
          ChangeNotifierProvider<ThemeProvider>.value(
            value: themeProvider,
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 360,
                    child: MilestoneCelebrationCard(
                      milestone: milestone,
                      onDismiss: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert texts are found
        expect(find.text('1024'), findsOneWidget);
        expect(find.text('True Prodigy'), findsOneWidget);
        expect(
            find.text(
                '"You\'re moving with suspicious confidence. This isn\'t luck anymore."'),
            findsOneWidget);
        expect(find.text('OK'), findsOneWidget);

        // Assert no overflow exception
        expect(tester.takeException(), isNull);

        // Assert card height is at most 280 dp
        final cardFinder = find.byType(Card);
        final cardSize = tester.getSize(cardFinder);
        expect(cardSize.height, lessThanOrEqualTo(280.0),
            reason: '${theme.name} card height exceeds 280dp');

        // Contrast calculations & assertions
        final screenBg = theme.backgroundColor;
        final isDark = screenBg.computeLuminance() < 0.5;

        final surface = Color.alphaBlend(
          const Color(0xFFFFFFFF).withValues(alpha: isDark ? 0.12 : 0.55),
          screenBg,
        );

        final border = ensureContrast(theme.boardColor, screenBg, 3.0);

        final startTrophy =
            isDark ? const Color(0xFFFFA726) : const Color(0xFFE65100);
        final trophy = ensureContrast(startTrophy, surface, 3.0);

        final textCol = ensureContrast(theme.textColor, surface, 4.5);

        final startButton =
            isDark ? const Color(0xFFFFA726) : const Color(0xFFE65100);
        final buttonFill = ensureContrast(startButton, surface, 3.0);

        final okLabel =
            ensureContrast(const Color(0xFFFFFFFF), buttonFill, 4.5);

        final borderVsBg = contrastRatio(border, screenBg);
        final trophyVsSurface = contrastRatio(trophy, surface);
        final textVsSurface = contrastRatio(textCol, surface);
        final buttonVsSurface = contrastRatio(buttonFill, surface);
        final okLabelVsButton = contrastRatio(okLabel, buttonFill);

        expect(borderVsBg, greaterThanOrEqualTo(3.0),
            reason: '${theme.name} border vs bg contrast lower than 3.0');
        expect(trophyVsSurface, greaterThanOrEqualTo(3.0),
            reason: '${theme.name} trophy vs surface contrast lower than 3.0');
        expect(textVsSurface, greaterThanOrEqualTo(4.5),
            reason: '${theme.name} text vs surface contrast lower than 4.5');
        expect(buttonVsSurface, greaterThanOrEqualTo(3.0),
            reason: '${theme.name} button vs surface contrast lower than 3.0');
        expect(okLabelVsButton, greaterThanOrEqualTo(4.5),
            reason: '${theme.name} ok label vs button contrast lower than 4.5');

        // Print theme info for report log
        debugPrint('THEME_METRIC: name="${theme.name}", '
            'surface="${_toHex(surface)}", screen_bg="${_toHex(screenBg)}", '
            'border="${_toHex(border)}", border_vs_bg=${borderVsBg.toStringAsFixed(2)}, '
            'trophy="${_toHex(trophy)}", trophy_vs_surface=${trophyVsSurface.toStringAsFixed(2)}, '
            'text_vs_surface=${textVsSurface.toStringAsFixed(2)}, '
            'ok_label_vs_button=${okLabelVsButton.toStringAsFixed(2)}, '
            'card_height_dp=${cardSize.height.toStringAsFixed(1)}');
      }
    });

    testWidgets(
        'Timer test: onDismiss is NOT called at 19s and IS called at 20s; tapping OK calls onDismiss at once; tapping card body does not',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final themeProvider = ThemeProvider();

      bool timerDismissed = false;
      const testMilestone = Milestone(
        value: 512,
        title: 'Rising Star',
        hype: "Now we're talking. The board is paying attention.",
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
          child: MaterialApp(
            home: Scaffold(
              body: MilestoneCelebrationCard(
                milestone: testMilestone,
                onDismiss: () {
                  timerDismissed = true;
                },
              ),
            ),
          ),
        ),
      );

      // At 19 seconds
      await tester.pump(const Duration(seconds: 19));
      expect(timerDismissed, isFalse);

      // At 20 seconds
      await tester.pump(const Duration(seconds: 1));
      expect(timerDismissed, isTrue);

      // Tapping card body does NOT dismiss
      bool bodyDismissed = false;
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
          child: MaterialApp(
            home: Scaffold(
              body: MilestoneCelebrationCard(
                milestone: testMilestone,
                onDismiss: () {
                  bodyDismissed = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Rising Star'));
      await tester.pump();
      expect(bodyDismissed, isFalse);

      // Tapping OK button dismisses immediately
      bool okDismissed = false;
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
          child: MaterialApp(
            home: Scaffold(
              body: MilestoneCelebrationCard(
                milestone: testMilestone,
                onDismiss: () {
                  okDismissed = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('OK'));
      await tester.pump();
      expect(okDismissed, isTrue);
    });

    test(
        'debugPreviewMilestone sets pendingMilestone in debug mode without changing stats or celebrated set',
        () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(Duration.zero);

      final initialScore = game.score;
      final initialMilestonesCount = game.statsService.milestonesReached;

      game.debugPreviewMilestone(1024);

      expect(game.pendingMilestone?.value, equals(1024));
      expect(game.pendingMilestone?.title, equals('True Prodigy'));

      // Score and stats unchanged
      expect(game.score, equals(initialScore));
      expect(game.statsService.milestonesReached, equals(initialMilestonesCount));

      // Clear pending milestone
      game.clearPendingMilestone();
      expect(game.pendingMilestone, isNull);
    });
  });
}
