import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../settings/providers/theme_provider.dart';
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
        if (game.isTimerMode) return const SizedBox.shrink();

        final target = game.currentGameTarget;
        final highest = game.highestTile;
        final fraction = progressFraction(highest, target);
        final currentBand = band(fraction);
        final motivation = MotivationLines.getLine(
          band: currentBand,
          moveCount: game.moveCount,
          target: target,
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
                      game.isDailyMode
                          ? 'DAILY GOAL $target'
                          : '${game.currentLevel.name} - GOAL $target',
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
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE65100)),
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
