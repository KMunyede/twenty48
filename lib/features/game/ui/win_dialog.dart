import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../levels/level_ladder.dart';

class WinDialog extends StatelessWidget {
  const WinDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final currentLevel = game.currentLevel;
    final nextLevel = Level.next(currentLevel.index);

    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('Level complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level: ${currentLevel.name}'),
            const SizedBox(height: 8),
            Text('Goal ${currentLevel.target} reached!'),
            if (currentLevel.index == 3) ...[
              const SizedBox(height: 12),
              const Text(
                'You are a GrandMaster!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (nextLevel != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await game.advanceToNextLevel();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text('Next: ${nextLevel.name} (${nextLevel.target})'),
            ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE65100),
            ),
            onPressed: () {
              game.continueAfterWin();
              Navigator.of(context).pop();
            },
            child: const Text('Keep going'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE65100),
            ),
            onPressed: () {
              game.continueAfterWin();
              game.initGame();
              Navigator.of(context).pop();
            },
            child: const Text('New game'),
          ),
        ],
      ),
    );
  }
}
