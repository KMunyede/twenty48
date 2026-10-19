import 'package:flutter_test/flutter_test.dart';
import 'package:twenty48/features/game/hud/goal_progress.dart';

void main() {
  group('GoalProgress Tests', () {
    test('progressFraction calculation and clamping', () {
      expect(progressFraction(2, 1024), closeTo(0.1, 0.001));
      expect(progressFraction(512, 1024), closeTo(0.9, 0.001));
      expect(progressFraction(0, 1024), 0.0);
      expect(progressFraction(1, 1024), 0.0);
      expect(progressFraction(2048, 1024), 1.0);
      expect(progressFraction(1024, 1024), 1.0);
    });

    test('band edges', () {
      expect(band(0.0), GoalBand.band0);
      expect(band(0.24), GoalBand.band0);
      expect(band(0.25), GoalBand.band1);
      expect(band(0.49), GoalBand.band1);
      expect(band(0.5), GoalBand.band2);
      expect(band(0.74), GoalBand.band2);
      expect(band(0.75), GoalBand.band3);
      expect(band(0.99), GoalBand.band3);
      expect(band(1.0), GoalBand.reached);
    });
  });
}
