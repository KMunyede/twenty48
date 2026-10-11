import 'package:shared_preferences/shared_preferences.dart';

class DailyChallengeService {
  final DateTime Function() _now;

  DailyChallengeService({DateTime Function()? now})
      : _now = now ?? DateTime.now;

  DateTime get _currentUtc => _now().toUtc();

  String todayKey() {
    final dt = _currentUtc;
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  int todaySeed() {
    final dt = _currentUtc;
    final year = dt.year;
    final month = dt.month;
    final day = dt.day;
    return year * 10000 + month * 100 + day;
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    final parts = dateStr.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime.utc(year, month, day);
  }

  Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  Future<bool> isTodayCompleted() async {
    try {
      final prefs = await _prefs();
      if (prefs == null) return false;
      final lastDate = prefs.getString('dailyLastCompletedDate');
      return lastDate == todayKey();
    } catch (_) {
      return false;
    }
  }

  Future<int> currentStreak() async {
    try {
      final prefs = await _prefs();
      if (prefs == null) return 0;
      final lastDateStr = prefs.getString('dailyLastCompletedDate');
      final streak = prefs.getInt('dailyStreak') ?? 0;
      if (lastDateStr == null || streak <= 0) return 0;

      final lastDateOnly = _parseDate(lastDateStr);
      if (lastDateOnly == null) return 0;

      final today = _currentUtc;
      final todayDateOnly = DateTime.utc(today.year, today.month, today.day);

      final difference = todayDateOnly.difference(lastDateOnly).inDays;
      if (difference == 0 || difference == 1) {
        return streak;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> markCompleted() async {
    try {
      final prefs = await _prefs();
      if (prefs == null) return 1;

      final todayKeyStr = todayKey();
      final lastDateStr = prefs.getString('dailyLastCompletedDate');
      final currentStoredStreak = prefs.getInt('dailyStreak') ?? 0;
      final currentBest = prefs.getInt('dailyBestStreak') ?? 0;

      if (lastDateStr == todayKeyStr) {
        return currentStoredStreak > 0 ? currentStoredStreak : 1;
      }

      int newStreak = 1;
      if (lastDateStr != null) {
        final lastDateOnly = _parseDate(lastDateStr);
        if (lastDateOnly != null) {
          final today = _currentUtc;
          final todayDateOnly = DateTime.utc(today.year, today.month, today.day);
          final difference = todayDateOnly.difference(lastDateOnly).inDays;

          if (difference == 1) {
            newStreak = currentStoredStreak + 1;
          } else {
            newStreak = 1;
          }
        }
      }

      final newBest = newStreak > currentBest ? newStreak : currentBest;

      await prefs.setString('dailyLastCompletedDate', todayKeyStr);
      await prefs.setInt('dailyStreak', newStreak);
      await prefs.setInt('dailyBestStreak', newBest);

      return newStreak;
    } catch (_) {
      return 1;
    }
  }
}
