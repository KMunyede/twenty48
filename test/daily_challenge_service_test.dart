import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twenty48/core/services/daily_challenge_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('same date gives same seed, different dates give different seeds', () {
    var fakeTime = DateTime.utc(2026, 10, 11, 12, 0);
    final service = DailyChallengeService(now: () => fakeTime);

    expect(service.todayKey(), '2026-10-11');
    expect(service.todaySeed(), 20261011);

    // Same date, different time -> same seed & key
    fakeTime = DateTime.utc(2026, 10, 11, 23, 59);
    expect(service.todayKey(), '2026-10-11');
    expect(service.todaySeed(), 20261011);

    // Different date
    fakeTime = DateTime.utc(2026, 10, 12, 0, 1);
    expect(service.todayKey(), '2026-10-12');
    expect(service.todaySeed(), 20261012);
  });

  test('streak progression and persistence logic', () async {
    var fakeTime = DateTime.utc(2026, 10, 11, 10, 0);
    final service = DailyChallengeService(now: () => fakeTime);

    // Initial state
    expect(await service.isTodayCompleted(), false);
    expect(await service.currentStreak(), 0);

    // First completion today
    var streak = await service.markCompleted();
    expect(streak, 1);
    expect(await service.isTodayCompleted(), true);
    expect(await service.currentStreak(), 1);

    // Same-day repeat does not increase
    streak = await service.markCompleted();
    expect(streak, 1);
    expect(await service.currentStreak(), 1);

    // Next-day completion gives 2
    fakeTime = DateTime.utc(2026, 10, 12, 9, 0); // Oct 12 (yesterday was Oct 11)
    expect(await service.isTodayCompleted(), false);
    expect(await service.currentStreak(), 1); // yesterday was completed, so streak is active

    streak = await service.markCompleted();
    expect(streak, 2);
    expect(await service.isTodayCompleted(), true);
    expect(await service.currentStreak(), 2);

    // A skipped day resets to 1 (skip Oct 13, jump to Oct 14)
    fakeTime = DateTime.utc(2026, 10, 14, 10, 0);
    expect(await service.currentStreak(), 0); // lapsed
    streak = await service.markCompleted();
    expect(streak, 1);
  });

  test('UTC rollover (23:59 UTC then 00:01 UTC counts as next day)', () async {
    var fakeTime = DateTime.utc(2026, 10, 11, 23, 59);
    final service = DailyChallengeService(now: () => fakeTime);

    // Complete on Oct 11 at 23:59 UTC
    var streak = await service.markCompleted();
    expect(streak, 1);
    expect(service.todayKey(), '2026-10-11');

    // Roll over to Oct 12 at 00:01 UTC (2 minutes later)
    fakeTime = DateTime.utc(2026, 10, 12, 0, 1);
    expect(service.todayKey(), '2026-10-12');
    expect(await service.currentStreak(), 1); // Active streak from yesterday (Oct 11)

    // Complete on Oct 12 -> should be streak 2
    streak = await service.markCompleted();
    expect(streak, 2);
  });
}
