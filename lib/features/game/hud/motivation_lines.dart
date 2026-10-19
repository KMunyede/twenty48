import 'goal_progress.dart';

class MotivationLines {
  static const List<String> band0Lines = [
    "Slide, merge, repeat. You've got this.",
    "Tip: keep your biggest tile in a corner.",
  ];

  static const List<String> band1Lines = [
    "Nice build-up! Keep one row for merges.",
    "Tip: slide in only 3 directions.",
  ];

  static const List<String> band2Lines = [
    "Over halfway to {goal}!",
    "Keep pushing toward {goal}!",
  ];

  static const List<String> band3Lines = [
    "So close! One smart merge at a time.",
    "Almost there. Breathe and plan ahead.",
  ];

  static const List<String> reachedLines = [
    "Goal reached!",
    "Fantastic! Target achieved!",
  ];

  static const List<String> gameOverLines = [
    "Every master started with a 2. Try again!",
    "Game over. Ready for another round?",
  ];

  static String getLine({
    required GoalBand band,
    required int moveCount,
    required int target,
    bool isGameOver = false,
  }) {
    if (isGameOver) {
      final template = gameOverLines[moveCount % gameOverLines.length];
      return template.replaceAll('{goal}', target.toString());
    }
    final List<String> lines = switch (band) {
      GoalBand.band0 => band0Lines,
      GoalBand.band1 => band1Lines,
      GoalBand.band2 => band2Lines,
      GoalBand.band3 => band3Lines,
      GoalBand.reached => reachedLines,
    };
    final template = lines[moveCount % lines.length];
    return template.replaceAll('{goal}', target.toString());
  }
}
