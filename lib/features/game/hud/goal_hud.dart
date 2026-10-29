import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../settings/providers/theme_provider.dart';
import '../milestones/milestone_ladder.dart';
import '../providers/game_provider.dart';
import 'goal_progress.dart';
import 'motivation_lines.dart';

class GoalHud extends StatelessWidget {
  const GoalHud({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final highest = game.highestTile;
        final next = nextMilestone(highest);

        final String headerText;
        final double fraction;
        final int targetVal;

        if (next != null) {
          headerText = 'NEXT: ${next.value} ${next.title}';
          targetVal = next.value;
          fraction = progressFraction(highest, next.value);
        } else {
          headerText = 'TOP MILESTONE - Walking Legend';
          targetVal = 131072;
          fraction = 1.0;
        }

        final currentBand = band(fraction);
        final motivation = MotivationLines.getLine(
          band: currentBand,
          moveCount: game.moveCount,
          target: targetVal,
          isGameOver: game.isGameOver,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      headerText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(fraction * 100).toInt()}%',
                    style: TextStyle(
                      color: theme.textColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 6,
                  backgroundColor: theme.textColor.withValues(alpha: 0.3),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFE65100)),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                motivation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textColor.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
