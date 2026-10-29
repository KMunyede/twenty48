import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twenty48/features/game/providers/game_provider.dart';
import 'package:twenty48/features/game/models/tile.dart';

void main() {
  group('GameProvider Target Value Tests', () {
    test('reaching target tile in Normal, Timer, and Daily mode does not end the game', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      // Normal mode (target 1024)
      game.setStandardMode();
      game.setTilesForTesting([
        Tile(id: '1', x: 0, y: 0, value: 512),
        Tile(id: '2', x: 0, y: 1, value: 512),
      ]);
      game.moveLeft();
      expect(game.highestTile, equals(1024));
      expect(game.isGameOver, isFalse);

      // Timer mode
      game.startTimerChallenge(1024);
      game.setTilesForTesting([
        Tile(id: '3', x: 0, y: 0, value: 512),
        Tile(id: '4', x: 0, y: 1, value: 512),
      ]);
      game.moveLeft();
      expect(game.highestTile, equals(1024));
      expect(game.isGameOver, isFalse);

      // Daily mode
      game.startDaily();
      game.setTilesForTesting([
        Tile(id: '5', x: 0, y: 0, value: 1024),
        Tile(id: '6', x: 0, y: 1, value: 1024),
      ]);
      game.moveLeft();
      expect(game.highestTile, equals(2048));
      expect(game.isGameOver, isFalse);
    });

    test('a merge creating a 256 tile sets pendingMilestone to the 256 milestone once and does not end the game', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      game.setStandardMode();
      game.setTilesForTesting([
        Tile(id: '1', x: 0, y: 0, value: 128),
        Tile(id: '2', x: 0, y: 1, value: 128),
      ]);
      game.moveLeft();

      expect(game.highestTile, equals(256));
      expect(game.pendingMilestone?.value, equals(256));
      expect(game.pendingMilestone?.title, equals('Great Tactician'));
      expect(game.isGameOver, isFalse);

      game.clearPendingMilestone();
      expect(game.pendingMilestone, isNull);

      // Undo and re-merge
      game.undo();
      game.moveLeft();
      // Must NOT celebrate again in the same game
      expect(game.pendingMilestone, isNull);
    });

    test('a merge creating a 512 tile sets pendingMilestone to the 512 milestone once and does not end the game', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      game.setStandardMode();
      game.setTilesForTesting([
        Tile(id: '1', x: 0, y: 0, value: 256),
        Tile(id: '2', x: 0, y: 1, value: 256),
      ]);
      game.moveLeft();

      expect(game.highestTile, equals(512));
      expect(game.pendingMilestone?.value, equals(512));
      expect(game.pendingMilestone?.title, equals('Rising Star'));
      expect(game.isGameOver, isFalse);

      game.clearPendingMilestone();
      expect(game.pendingMilestone, isNull);

      // Undo and re-merge
      game.undo();
      game.moveLeft();
      // Must NOT celebrate again in the same game
      expect(game.pendingMilestone, isNull);
    });

    test('a merge reaching 1024 sets pendingMilestone once, game does not end, undo/re-merge does not celebrate again, new game clears set', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      game.setStandardMode();
      game.setTilesForTesting([
        Tile(id: '1', x: 0, y: 0, value: 512),
        Tile(id: '2', x: 0, y: 1, value: 512),
      ]);
      game.moveLeft();

      expect(game.pendingMilestone?.value, equals(1024));
      expect(game.pendingMilestone?.title, equals('True Prodigy'));
      expect(game.isGameOver, isFalse);

      game.clearPendingMilestone();
      expect(game.pendingMilestone, isNull);

      // Undo and re-merge
      game.undo();
      game.moveLeft();
      // Must NOT celebrate again in the same game
      expect(game.pendingMilestone, isNull);

      // New game clears the celebrated set
      game.initGame();
      game.setTilesForTesting([
        Tile(id: '3', x: 0, y: 0, value: 512),
        Tile(id: '4', x: 0, y: 1, value: 512),
      ]);
      game.moveLeft();
      expect(game.pendingMilestone?.value, equals(1024));
    });
  });
}
