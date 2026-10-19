import 'package:shared_preferences/shared_preferences.dart';

class LevelService {
  final Future<SharedPreferences> Function()? _prefsLoader;
  SharedPreferences? _prefs;

  int _currentLevel = 1;

  int get currentLevel => _currentLevel;

  LevelService({
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
      final raw = prefs.getInt('playerLevel') ?? 1;
      _currentLevel = raw.clamp(1, 3);
    } catch (_) {
      _currentLevel = 1;
    }
  }

  Future<void> saveLevel(int level) async {
    try {
      _currentLevel = level.clamp(1, 3);
      final prefs = await _getPrefs();
      await prefs.setInt('playerLevel', _currentLevel);
    } catch (_) {
      // Ignore write errors
    }
  }
}
