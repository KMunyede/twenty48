import 'package:flutter_test/flutter_test.dart';
import 'package:twenty48/features/game/hud/goal_progress.dart';
import 'package:twenty48/features/game/hud/motivation_lines.dart';

void main() {
  group('MotivationLines Tests', () {
    test('all bands return non-empty string <= 48 chars with {goal} replaced', () {
      for (var band in GoalBand.values) {
        for (int move = 0; move < 2; move++) {
          final line = MotivationLines.getLine(
            band: band,
            moveCount: move,
            target: 1024,
          );
          expect(line, isNotEmpty);
          expect(line.length, lessThanOrEqualTo(48));
          if (band == GoalBand.band2) {
            expect(line.contains('1024'), true);
          }
        }
      }
    });

    test('game over line', () {
      final line = MotivationLines.getLine(
        band: GoalBand.band0,
        moveCount: 0,
        target: 2048,
        isGameOver: true,
      );
      expect(line, isNotEmpty);
      expect(line.length, lessThanOrEqualTo(48));
    });

    test('parity switches variants', () {
      final line1 = MotivationLines.getLine(
        band: GoalBand.band0,
        moveCount: 0,
        target: 1024,
      );
      final line2 = MotivationLines.getLine(
        band: GoalBand.band0,
        moveCount: 1,
        target: 1024,
      );
      expect(line1 != line2, true);
    });
  });
}
