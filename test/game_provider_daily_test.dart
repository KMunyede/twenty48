import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twenty48/features/game/providers/game_provider.dart';
import 'package:twenty48/core/services/daily_challenge_service.dart';

class FakeDailyChallengeService extends DailyChallengeService {
  final int fixedSeed;
  bool markedCompletedCalled = false;

  FakeDailyChallengeService({this.fixedSeed = 20250101})
      : super(now: () => DateTime(2025, 1, 1));

  @override
  int todaySeed() => fixedSeed;

  @override
  Future<int> markCompleted() async {
    markedCompletedCalled = true;
    return 1;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameProvider Daily Mode Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('startDaily sets isDailyMode and initializes board', () async {
      final dailyService = FakeDailyChallengeService(fixedSeed: 20250101);
      final provider = GameProvider(dailyService: dailyService);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.isDailyMode, isFalse);
      provider.startDaily();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(provider.isDailyMode, isTrue);
      expect(provider.tiles.length, 2);
    });

    test('startDaily twice gives an identical starting board', () async {
      final service1 = FakeDailyChallengeService(fixedSeed: 20250101);
      final p1 = GameProvider(dailyService: service1);
      await Future.delayed(const Duration(milliseconds: 100));
      p1.startDaily();
      await Future.delayed(const Duration(milliseconds: 100));
      final tiles1 = p1.tiles.map((t) => '${t.x},${t.y}:${t.value}').toList();

      final service2 = FakeDailyChallengeService(fixedSeed: 20250101);
      final p2 = GameProvider(dailyService: service2);
      await Future.delayed(const Duration(milliseconds: 100));
      p2.startDaily();
      await Future.delayed(const Duration(milliseconds: 100));
      final tiles2 = p2.tiles.map((t) => '${t.x},${t.y}:${t.value}').toList();

      expect(tiles1, equals(tiles2));
    });

    test('calling initGame() while in daily mode gives the same starting board again', () async {
      final service = FakeDailyChallengeService(fixedSeed: 20250101);
      final provider = GameProvider(dailyService: service);
      await Future.delayed(const Duration(milliseconds: 100));
      provider.startDaily();
      await Future.delayed(const Duration(milliseconds: 100));
      final tiles1 = provider.tiles.map((t) => '${t.x},${t.y}:${t.value}').toList();

      provider.initGame();
      await Future.delayed(const Duration(milliseconds: 100));

      final tiles2 = provider.tiles.map((t) => '${t.x},${t.y}:${t.value}').toList();
      expect(tiles1, equals(tiles2));
    });

    test('after setStandardMode the daily seed is no longer used (isDailyMode false)', () async {
      final service = FakeDailyChallengeService(fixedSeed: 20250101);
      final provider = GameProvider(dailyService: service);
      await Future.delayed(const Duration(milliseconds: 100));
      provider.startDaily();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(provider.isDailyMode, isTrue);

      provider.setStandardMode();
      expect(provider.isDailyMode, isFalse);
    });

    test('startDaily does not change saved targetValue or isTimerMode keys', () async {
      SharedPreferences.setMockInitialValues({
        'targetValue': 2048,
        'isTimerMode': true,
      });

      final service = FakeDailyChallengeService();
      final provider = GameProvider(dailyService: service);
      await Future.delayed(const Duration(milliseconds: 100));

      provider.startDaily();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('targetValue'), equals(2048));
      expect(prefs.getBool('isTimerMode'), isTrue);
    });
  });
}
