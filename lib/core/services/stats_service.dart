import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  final Future<SharedPreferences> Function()? _prefsLoader;
  SharedPreferences? _prefs;

  int _gamesPlayed = 0;
  int _wins = 0;
  int _bestTile = 0;
  int _milestonesReached = 0;

  int get gamesPlayed => _gamesPlayed;
  int get wins => _wins;
  int get bestTile => _bestTile;
  int get milestonesReached => _milestonesReached;

  double get winRate => _gamesPlayed > 0 ? (_wins / _gamesPlayed) * 100 : 0.0;
  String get formattedWinRate =>
      _gamesPlayed > 0 ? '${winRate.toStringAsFixed(0)}%' : '-';

  StatsService({
    SharedPreferences? prefs,
    Future<SharedPreferences> Function()? prefsLoader,
  })  : _prefs = prefs,
        _prefsLoader = prefsLoader;

  Future<SharedPreferences> _getPrefs() async {
    final currentPrefs = _prefs;
    if (currentPrefs != null) return currentPrefs;
    final loader = _prefsLoader;
    if (loader != null) {
      final loaded = await loader();
      _prefs = loaded;
      return loaded;
    }
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    return prefs;
  }

  Future<void> load() async {
    try {
      final prefs = await _getPrefs();
      _gamesPlayed = prefs.getInt('stats_gamesPlayed') ?? 0;
      _wins = prefs.getInt('stats_wins') ?? 0;
      _bestTile = prefs.getInt('stats_bestTile') ?? 0;
      _milestonesReached = prefs.getInt('stats_milestones') ?? 0;
    } catch (_) {
      // Keep defaults on error
    }
  }

  Future<void> recordMilestone(int value) async {
    try {
      await load();
      _bestTile = max(_bestTile, value);
      _milestonesReached += 1;

      final prefs = await _getPrefs();
      await prefs.setInt('stats_bestTile', _bestTile);
      await prefs.setInt('stats_milestones', _milestonesReached);
    } catch (_) {
      // Ignore write errors
    }
  }

  Future<void> recordGameEnd({
    required bool won,
    required int highestTile,
  }) async {
    try {
      await load();
      _gamesPlayed += 1;
      if (won) {
        _wins += 1;
      }
      _bestTile = max(_bestTile, highestTile);

      final prefs = await _getPrefs();
      await prefs.setInt('stats_gamesPlayed', _gamesPlayed);
      await prefs.setInt('stats_wins', _wins);
      await prefs.setInt('stats_bestTile', _bestTile);
    } catch (_) {
      // Ignore write errors
    }
  }
}
