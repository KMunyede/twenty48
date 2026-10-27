import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twenty48/features/game/models/tile.dart';
import 'package:twenty48/features/game/providers/game_provider.dart';

void main() {
  group('GameProvider Merge Window Tests (T48-78J)', () {
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

    test('a. 16 live tiles on 16 squares, no equal neighbours, plus one tile animating out on an occupied square: isGameOver is true', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      game.setStandardMode();

      List<Tile> tiles = fullBoardNoMatches();
      // Add one tile animating out on an occupied square (0,0)
      tiles.add(Tile(x: 0, y: 0, value: 2, id: 'deleting_1', isDeleting: true));

      game.setTilesForTesting(tiles);

      expect(game.isGameOver, isTrue);
    });

    test('b. 15 live tiles on 15 squares (one empty square), plus one tile animating out on an occupied square: isGameOver is false', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      game.setStandardMode();

      List<Tile> tiles = fullBoardNoMatches();
      // Remove one live tile so there are 15 live tiles on 15 squares
      tiles.removeWhere((t) => t.x == 3 && t.y == 3);
      // Add one tile animating out on an occupied square (0,0)
      tiles.add(Tile(x: 0, y: 0, value: 2, id: 'deleting_1', isDeleting: true));

      game.setTilesForTesting(tiles);

      expect(game.isGameOver, isFalse);
    });

    test('c. A move straight after a merge does not move or merge a tile that is animating out', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      game.setStandardMode();

      List<Tile> testTiles = [
        Tile(x: 0, y: 0, value: 2, id: 't1'),
        Tile(x: 0, y: 1, value: 2, id: 't2'),
      ];
      game.setTilesForTesting(testTiles);

      // First move creates a merged tile and a deleting tile at (0,0)
      game.moveLeft();

      // Verify deleting tile exists in tiles immediately after move
      expect(game.tiles.any((t) => t.isDeleting), isTrue);

      // Perform a second move immediately straight after the merge (without waiting 250ms)
      game.moveRight();

      // Verify that no tiles remaining in game.tiles have isDeleting == true,
      // and the deleting tile was purged without being moved or merged.
      expect(game.tiles.any((t) => t.isDeleting), isFalse);
      final tileValues = game.tiles.where((t) => !t.isDeleting).map((t) => t.value).toList();
      // Merged tile of value 4 moved right to x=0,y=3, plus one newly spawned tile (2 or 4)
      expect(tileValues.contains(4), isTrue);
    });

    test('d. Undo history never contains a tile that is animating out', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      game.setStandardMode();

      List<Tile> testTiles = [
        Tile(x: 0, y: 0, value: 2, id: 't1'),
        Tile(x: 0, y: 1, value: 2, id: 't2'),
      ];
      game.setTilesForTesting(testTiles);

      // Move left to cause merge
      game.moveLeft();

      // Verify undo is available
      expect(game.canUndo, isTrue);

      // Perform undo
      game.undo();

      // Verify none of the restored tiles are marked as deleting
      expect(game.tiles.any((t) => t.isDeleting), isFalse);
      expect(game.tiles.length, equals(2));
      expect(game.tiles[0].value, equals(2));
      expect(game.tiles[1].value, equals(2));
    });
  });
}
