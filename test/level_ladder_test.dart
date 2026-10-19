import 'package:flutter_test/flutter_test.dart';
import 'package:twenty48/features/game/levels/level_ladder.dart';

void main() {
  group('LevelLadder Tests', () {
    test('levels list contains apprentice, expert, grandmaster', () {
      expect(Level.levels.length, equals(3));
      expect(Level.levels[0].name, equals('Apprentice'));
      expect(Level.levels[0].target, equals(1024));
      expect(Level.levels[0].headStart, equals(0));

      expect(Level.levels[1].name, equals('Expert'));
      expect(Level.levels[1].target, equals(2048));
      expect(Level.levels[1].headStart, equals(256));

      expect(Level.levels[2].name, equals('GrandMaster'));
      expect(Level.levels[2].target, equals(8192));
      expect(Level.levels[2].headStart, equals(512));
    });

    test('byIndex clamps invalid values', () {
      expect(Level.byIndex(0).index, equals(1));
      expect(Level.byIndex(1).index, equals(1));
      expect(Level.byIndex(2).index, equals(2));
      expect(Level.byIndex(3).index, equals(3));
      expect(Level.byIndex(99).index, equals(3));
    });

    test('next returns correct next level or null', () {
      expect(Level.next(1)?.index, equals(2));
      expect(Level.next(2)?.index, equals(3));
      expect(Level.next(3), isNull);
    });
  });
}
