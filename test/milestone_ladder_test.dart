import 'package:flutter_test/flutter_test.dart';
import 'package:twenty48/features/game/milestones/milestone_ladder.dart';

void main() {
  group('Milestone Ladder Tests', () {
    test('table has 9 entries in ascending order', () {
      expect(milestoneLadder.length, equals(9));
      for (int i = 0; i < milestoneLadder.length - 1; i++) {
        expect(
          milestoneLadder[i].value,
          lessThan(milestoneLadder[i + 1].value),
        );
      }
    });

    test('titleForBestTile at 0, 511, 512, 1023, 1024, 2047, 2048, 4096, 8192, 131072, 262144',
        () {
      expect(titleForBestTile(0), isNull);
      expect(titleForBestTile(511), isNull);
      expect(titleForBestTile(512), equals('Rising Star'));
      expect(titleForBestTile(1023), equals('Rising Star'));
      expect(titleForBestTile(1024), equals('Certified Prodigy'));
      expect(titleForBestTile(2047), equals('Certified Prodigy'));
      expect(titleForBestTile(2048), equals('Undisputed Champion'));
      expect(titleForBestTile(4096), equals('Big Brain Specialist'));
      expect(titleForBestTile(8192), equals('Cold-Blooded Tactician'));
      expect(titleForBestTile(131072), equals('Walking Legend'));
      expect(titleForBestTile(262144), equals('Walking Legend'));
    });

    test('nextMilestone at 0, 512, 1024, 131072', () {
      expect(nextMilestone(0)?.value, equals(512));
      expect(nextMilestone(512)?.value, equals(1024));
      expect(nextMilestone(1024)?.value, equals(2048));
      expect(nextMilestone(131072), isNull);
    });
  });
}
