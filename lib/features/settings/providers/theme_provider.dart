// lib/features/settings/providers/theme_provider.dart

import 'package:flutter/material.dart';
import '../models/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.themes.firstWhere((t) => t.name == 'Rhino Grey', orElse: () => AppTheme.themes[0]);

  AppTheme get currentTheme => _currentTheme;

  void setTheme(AppTheme theme) {
    _currentTheme = theme;
    notifyListeners();
  }
}
