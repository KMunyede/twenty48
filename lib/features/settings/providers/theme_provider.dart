// lib/features/settings/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.themes.firstWhere((t) => t.name == 'Rhino Grey', orElse: () => AppTheme.themes[0]);

  AppTheme get currentTheme => _currentTheme;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('selectedTheme');
    if (themeName != null) {
      _currentTheme = AppTheme.themes.firstWhere(
        (t) => t.name == themeName,
        orElse: () => _currentTheme,
      );
      notifyListeners();
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTheme', theme.name);
  }
}
