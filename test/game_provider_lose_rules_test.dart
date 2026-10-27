import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twenty48/features/game/models/tile.dart';
import 'package:twenty48/features/game/providers/game_provider.dart';

void main() {
  group('GameProvider Lose Rules Tests (T48-78G)', () {
    List<Tile> fullBoardNoMatches() {
      List<Tile> tiles = [];
      int id = 1;
      for (int x = 0; x < 4; x++) {
        for (int y = 0; y < 4; y++) {
          int value = ((x + y) % 2 == 0) ? 2 : 4;
          tiles.add(Tile(x: x, y: y, value: value, id: '${id++}'));
        }
      }
      return tiles;
    }

    test('a. Normal mode, full board, no equal neighbours: isGameOver is true', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      game.setStandardMode();
      game.setTilesForTesting(fullBoardNoMatches());

      expect(game.isGameOver, isTrue);
    });

    test('b. Normal mode, one empty cell with tiles that can slide: isGameOver is false', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      game.setStandardMode();
      List<Tile> tiles = fullBoardNoMatches();
      tiles.removeWhere((t) => t.x == 3 && t.y == 3);
      game.setTilesForTesting(tiles);

      expect(game.isGameOver, isFalse);
    });

    test('c. Normal mode, full board with one equal neighbour pair: isGameOver is false', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      game.setStandardMode();
      List<Tile> tiles = fullBoardNoMatches();
      final idx = tiles.indexWhere((t) => t.x == 3 && t.y == 3);
      tiles[idx] = tiles[idx].copyWith(value: 4);
      game.setTilesForTesting(tiles);

      expect(game.isGameOver, isFalse);
    });

    test('d. Normal mode, remaining seconds set to 0: isGameOver is false', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      game.setStandardMode();
      game.setRemainingSecondsForTesting(0);

      expect(game.isGameOver, isFalse);
    });

    test('e. Timer mode, remaining seconds 0: isGameOver is true', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      game.startTimerChallenge(1024);
      game.setRemainingSecondsForTesting(0);

      expect(game.isGameOver, isTrue);
    });

    test('f. Timer mode, time left and legal moves exist: isGameOver is false', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      game.startTimerChallenge(1024);
      game.setRemainingSecondsForTesting(300);

      expect(game.isGameOver, isFalse);
    });

    test('g. A move while the game is over leaves the board unchanged', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      game.setStandardMode();
      game.setTilesForTesting(fullBoardNoMatches());

      expect(game.isGameOver, isTrue);
      final initialValues = game.tiles.map((t) => t.value).toList();

      final moved = game.moveLeft();
      expect(moved, isFalse);
      expect(game.tiles.map((t) => t.value).toList(), equals(initialValues));
    });

    test('h. Undo after a game over restores a playable board', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      game.setStandardMode();

      List<Tile> playableTiles = [
        Tile(x: 0, y: 1, value: 2, id: '1'),
      ];
      game.setTilesForTesting(playableTiles);
      expect(game.isGameOver, isFalse);

      final moved = game.moveLeft();
      expect(moved, isTrue);
      expect(game.canUndo, isTrue);

      game.setTilesForTesting(fullBoardNoMatches());
      expect(game.isGameOver, isTrue);

      game.undo();

      expect(game.isGameOver, isFalse);
    });

    test('i. Timer target reached: isGameOver is true, and win behaviour is unchanged', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      game.startTimerChallenge(128);

      List<Tile> testTiles = [
        Tile(x: 0, y: 0, value: 64, id: '1'),
        Tile(x: 0, y: 1, value: 64, id: '2'),
      ];
      game.setTilesForTesting(testTiles);

      expect(game.isGameOver, isFalse);

      game.moveLeft();

      expect(game.isGameOver, isTrue);
    });
  });
}
