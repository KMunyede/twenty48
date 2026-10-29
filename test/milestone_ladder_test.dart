import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty48/features/game/hud/goal_progress.dart';
import 'package:twenty48/features/game/milestones/milestone_ladder.dart';

Future<void> loadRobotoFont() async {
  final fontLoader = FontLoader('Roboto');
  final boldFile = File(
      r'C:\Users\Keepy\Documents\ProgramFiles\flutter\bin\cache\artifacts\material_fonts\roboto-bold.ttf');
  if (boldFile.existsSync()) {
    final bytes = await boldFile.readAsBytes();
    fontLoader.addFont(Future.value(ByteData.sublistView(bytes)));
    await fontLoader.load();
  }
}

void main() {
  group('Milestone Ladder Tests', () {
    test('table has 10 entries in ascending order with exact titles', () {
      expect(milestoneLadder.length, equals(10));
      for (int i = 0; i < milestoneLadder.length - 1; i++) {
        expect(
          milestoneLadder[i].value,
          lessThan(milestoneLadder[i + 1].value),
        );
      }
      expect(milestoneLadder[0].title, equals('Great Tactician'));
      expect(milestoneLadder[1].title, equals('Rising Star'));
      expect(milestoneLadder[2].title, equals('True Prodigy'));
      expect(milestoneLadder[3].title, equals('Grand Champion'));
      expect(milestoneLadder[4].title, equals('Big Brain'));
      expect(milestoneLadder[5].title, equals('Cold Blooded'));
      expect(milestoneLadder[6].title, equals('Board Royalty'));
      expect(milestoneLadder[7].title, equals('The Untouchable'));
      expect(milestoneLadder[8].title, equals('Mythic Menace'));
      expect(milestoneLadder[9].title, equals('Walking Legend'));
    });

    test(
        'titleForBestTile at 255 (null), 256, 511, 512, 1023, 1024, 2048, 4096, 8192, 131072, 262144',
        () {
      expect(titleForBestTile(255), isNull);
      expect(titleForBestTile(256), equals('Great Tactician'));
      expect(titleForBestTile(511), equals('Great Tactician'));
      expect(titleForBestTile(512), equals('Rising Star'));
      expect(titleForBestTile(1023), equals('Rising Star'));
      expect(titleForBestTile(1024), equals('True Prodigy'));
      expect(titleForBestTile(2048), equals('Grand Champion'));
      expect(titleForBestTile(4096), equals('Big Brain'));
      expect(titleForBestTile(8192), equals('Cold Blooded'));
      expect(titleForBestTile(131072), equals('Walking Legend'));
      expect(titleForBestTile(262144), equals('Walking Legend'));
    });

    test('nextMilestone at 0 (256), 256 (512), 131072 (null)', () {
      expect(nextMilestone(0)?.value, equals(256));
      expect(nextMilestone(256)?.value, equals(512));
      expect(nextMilestone(512)?.value, equals(1024));
      expect(nextMilestone(131072), isNull);
    });

    test('goalLineText at highestTile 2, 256, 8192, 65536, and 131072', () {
      expect(goalLineText(2),
          equals('Your Next Big Tile: 256 - Great Tactician'));
      expect(goalLineText(256), equals('Your Next Big Tile: 512 - Rising Star'));
      expect(goalLineText(8192),
          equals('Your Next Big Tile: 16384 - Board Royalty'));
      expect(goalLineText(65536),
          equals('Your Next Big Tile: 131072 - Walking Legend'));
      expect(goalLineText(131072), equals('TOP MILESTONE - Walking Legend'));
    });

    test('Width test: all 10 goal lines do not overflow in 360 dp wide layout',
        () async {
      await loadRobotoFont();

      final tilesToTest = [
        0,
        256,
        512,
        1024,
        2048,
        4096,
        8192,
        16384,
        32768,
        65536
      ];
      for (final t in tilesToTest) {
        final next = nextMilestone(t);
        final fraction = next != null ? progressFraction(t, next.value) : 1.0;
        final pctStr = '${(fraction * 100).toInt()}%';

        final pctPainter = TextPainter(
          text: TextSpan(
            text: pctStr,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final availableWidth = 360.0 - 32.0 - 8.0 - pctPainter.width;
        final line = goalLineText(t);

        final unconstrainedPainter = TextPainter(
          text: TextSpan(
            text: line,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();

        final painter = TextPainter(
          text: TextSpan(
            text: line,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout(maxWidth: availableWidth);

        expect(
          painter.didExceedMaxLines,
          isFalse,
          reason:
              'Line "$line" for tile $t exceeded maxLines (unconstrained width: ${unconstrainedPainter.width}, available: $availableWidth)',
        );
      }
    });
  });
}
