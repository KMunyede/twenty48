import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twenty48/features/game/providers/game_provider.dart';
import 'package:twenty48/features/game/levels/level_service.dart';

void main() {
  group('GameProvider Win Flow & Level Ladder Tests', () {
    test('Challenge and Daily never set winPromptPending', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      game.startTimerChallenge(1024);
      expect(game.winPromptPending, isFalse);

      game.startDaily();
      expect(game.winPromptPending, isFalse);
    });

    test('advanceToNextLevel raises level, increments undo, resets game', () async {
      SharedPreferences.setMockInitialValues({'playerLevel': 1});
      final levelService = LevelService();
      await levelService.load();

      final game = GameProvider(levelService: levelService);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(game.currentLevel.index, equals(1));
      
      await game.advanceToNextLevel();
      expect(game.currentLevel.index, equals(2));
      expect(game.winPromptPending, isFalse);
      expect(game.undoCharges, equals(4)); // 3 + 1
    });

    test('continueAfterWin clears pending prompt', () async {
      SharedPreferences.setMockInitialValues({'playerLevel': 1});
      final levelService = LevelService();
      await levelService.load();

      final game = GameProvider(levelService: levelService);
      await Future.delayed(const Duration(milliseconds: 100));

      game.continueAfterWin();
      expect(game.winPromptPending, isFalse);
    });
  });
}
