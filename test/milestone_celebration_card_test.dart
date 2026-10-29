import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twenty48/features/game/milestones/milestone_celebration.dart';
import 'package:twenty48/features/game/milestones/milestone_ladder.dart';
import 'package:twenty48/features/game/providers/game_provider.dart';
import 'package:twenty48/features/settings/models/app_theme.dart';
import 'package:twenty48/features/settings/providers/theme_provider.dart';

double contrastRatio(Color c1, Color c2) {
  final l1 = c1.computeLuminance();
  final l2 = c2.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MilestoneCelebrationCard Tests', () {
    testWidgets(
        'Widget test: for EVERY theme, builds inside 360dp width without overflow, texts found, contrast >= 4.5',
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

        // Assert no overflow
        expect(tester.takeException(), isNull);

        // Contrast assertions
        final bg = theme.backgroundColor;
        final titleColor = MilestoneCelebrationCard.getCardTextColor(theme);
        final hypeColor = MilestoneCelebrationCard.getCardHypeColor(theme);

        final hypeComposite = Color.alphaBlend(hypeColor, bg);

        final crTitle = contrastRatio(bg, titleColor);
        final crHype = contrastRatio(bg, hypeComposite);

        expect(crTitle, greaterThanOrEqualTo(4.5),
            reason: '${theme.name} title contrast lower than 4.5');
        expect(crHype, greaterThanOrEqualTo(4.5),
            reason: '${theme.name} hype contrast lower than 4.5');
      }
    });

    testWidgets(
        'Timer test: onDismiss is NOT called at 5s and IS called at 6s; tapping calls onDismiss at once',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final themeProvider = ThemeProvider();

      bool dismissed = false;
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
                  dismissed = true;
                },
              ),
            ),
          ),
        ),
      );

      // At 5 seconds
      await tester.pump(const Duration(seconds: 5));
      expect(dismissed, isFalse);

      // At 6 seconds
      await tester.pump(const Duration(seconds: 1));
      expect(dismissed, isTrue);

      // Tap to dismiss
      bool tapDismissed = false;
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
          child: MaterialApp(
            home: Scaffold(
              body: MilestoneCelebrationCard(
                milestone: testMilestone,
                onDismiss: () {
                  tapDismissed = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MilestoneCelebrationCard));
      expect(tapDismissed, isTrue);
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
