import 'package:shared_preferences/shared_preferences.dart';

class WelcomeService {
  final Future<SharedPreferences> Function()? _prefsLoader;
  SharedPreferences? _prefs;

  WelcomeService({
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

  Future<bool> get seen async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool('welcome_climb_seen_v1') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> markSeen() async {
    try {
      final prefs = await _getPrefs();
      await prefs.setBool('welcome_climb_seen_v1', true);
    } catch (_) {
      // Ignore errors
    }
  }
}
