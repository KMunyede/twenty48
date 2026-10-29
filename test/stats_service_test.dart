import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twenty48/core/services/stats_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('StatsService', () {
    test('initial values are zero and formattedWinRate is -', () async {
      final service = StatsService();
      await service.load();

      expect(service.gamesPlayed, equals(0));
      expect(service.wins, equals(0));
      expect(service.bestTile, equals(0));
      expect(service.winRate, equals(0.0));
      expect(service.formattedWinRate, equals('-'));
    });

    test('recordGameEnd increments counts and updates win rate and bestTile',
        () async {
      final service = StatsService();
      await service.load();

      await service.recordGameEnd(won: false, highestTile: 512);
      expect(service.gamesPlayed, equals(1));
      expect(service.wins, equals(0));
      expect(service.bestTile, equals(512));
      expect(service.formattedWinRate, equals('0%'));

      await service.recordGameEnd(won: true, highestTile: 1024);
      expect(service.gamesPlayed, equals(2));
      expect(service.wins, equals(1));
      expect(service.bestTile, equals(1024));
      expect(service.formattedWinRate, equals('50%'));
    });

    test('bestTile retains maximum value when smaller highestTile is recorded',
        () async {
      final service = StatsService();
      await service.recordGameEnd(won: true, highestTile: 2048);
      expect(service.bestTile, equals(2048));

      await service.recordGameEnd(won: false, highestTile: 256);
      expect(service.bestTile, equals(2048));
    });

    test('persistence across instances', () async {
      final service1 = StatsService();
      await service1.recordGameEnd(won: true, highestTile: 1024);

      final service2 = StatsService();
      await service2.load();
      expect(service2.gamesPlayed, equals(1));
      expect(service2.wins, equals(1));
      expect(service2.bestTile, equals(1024));
    });

    test('recordMilestone raises bestTile only if larger, increments milestonesReached each call, and persists',
        () async {
      final service1 = StatsService();
      await service1.load();
      expect(service1.milestonesReached, equals(0));

      await service1.recordMilestone(1024);
      expect(service1.bestTile, equals(1024));
      expect(service1.milestonesReached, equals(1));

      await service1.recordMilestone(512); // smaller than 1024
      expect(service1.bestTile, equals(1024));
      expect(service1.milestonesReached, equals(2));

      await service1.recordMilestone(2048); // larger
      expect(service1.bestTile, equals(2048));
      expect(service1.milestonesReached, equals(3));

      final service2 = StatsService();
      await service2.load();
      expect(service2.bestTile, equals(2048));
      expect(service2.milestonesReached, equals(3));
    });
  });
}
