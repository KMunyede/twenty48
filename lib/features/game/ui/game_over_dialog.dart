import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final String title;
  final String message;
  final int score;
  final int bestScore;
  final String? levelName;
  final bool canUndo;
  final VoidCallback onNewGame;
  final VoidCallback? onUndo;
  final VoidCallback onViewBoard;

  const GameOverDialog({
    super.key,
    required this.title,
    required this.message,
    required this.score,
    required this.bestScore,
    this.levelName,
    required this.canUndo,
    required this.onNewGame,
    this.onUndo,
    required this.onViewBoard,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          onViewBoard();
        }
      },
      child: AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 12),
            if (levelName != null) ...[
              Text('Level: $levelName'),
              const SizedBox(height: 6),
            ],
            Text('Score: $score'),
            const SizedBox(height: 6),
            Text('Best: $bestScore'),
          ],
        ),
        actions: [
          if (canUndo && onUndo != null)
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE65100),
              ),
              onPressed: onUndo,
              child: const Text('Undo last move'),
            ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE65100),
            ),
            onPressed: onViewBoard,
            child: const Text('View board'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              foregroundColor: Colors.white,
            ),
            onPressed: onNewGame,
            child: const Text('New game'),
          ),
        ],
      ),
    );
  }
}
