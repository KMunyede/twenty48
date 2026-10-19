class Level {
  final int index;
  final String name;
  final int target;
  final int headStart;

  const Level({
    required this.index,
    required this.name,
    required this.target,
    required this.headStart,
  });

  static const List<Level> levels = [
    Level(index: 1, name: 'Apprentice', target: 1024, headStart: 0),
    Level(index: 2, name: 'Expert', target: 2048, headStart: 256),
    Level(index: 3, name: 'GrandMaster', target: 8192, headStart: 512),
  ];

  static Level byIndex(int index) {
    final clamped = index.clamp(1, levels.length);
    return levels.firstWhere((l) => l.index == clamped, orElse: () => levels.first);
  }

  static Level? next(int currentIndex) {
    if (currentIndex >= levels.length) return null;
    return levels.firstWhere((l) => l.index == currentIndex + 1, orElse: () => levels.last);
  }
}
