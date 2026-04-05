// lib/features/settings/models/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  final Color backgroundColor;
  final Color boardColor;
  final Color emptyTileColor;
  final Color scoreTileColor;
  final Color textColor;

  AppTheme({
    required this.name,
    required this.backgroundColor,
    required this.boardColor,
    required this.emptyTileColor,
    required this.scoreTileColor,
    required this.textColor,
  });

  static final List<AppTheme> themes = [
    AppTheme(
      name: 'Turtle green',
      backgroundColor: const Color(0xFFE8F5E9),
      boardColor: const Color(0xFF81C784),
      emptyTileColor: const Color(0xFFA5D6A7),
      scoreTileColor: const Color(0xFF66BB6A),
      textColor: const Color(0xFF2E7D32),
    ),
    AppTheme(
      name: 'Rare Indigo',
      backgroundColor: const Color(0xFFE8EAF6),
      boardColor: const Color(0xFF7986CB),
      emptyTileColor: const Color(0xFF9FA8DA),
      scoreTileColor: const Color(0xFF5C6BC0),
      textColor: const Color(0xFF283593),
    ),
    AppTheme(
      name: 'Sunset Orange',
      backgroundColor: const Color(0xFFFFF3E0),
      boardColor: const Color(0xFFFFB74D),
      emptyTileColor: const Color(0xFFFFCC80),
      scoreTileColor: const Color(0xFFFFA726),
      textColor: const Color(0xFFE65100),
    ),
    AppTheme(
      name: 'Oceanic Blue',
      backgroundColor: const Color(0xFFE1F5FE),
      boardColor: const Color(0xFF4FC3F7),
      emptyTileColor: const Color(0xFF81D4FA),
      scoreTileColor: const Color(0xFF29B6F6),
      textColor: const Color(0xFF01579B),
    ),
    AppTheme(
      name: 'Arctic White',
      backgroundColor: const Color(0xFFE0E0E0),
      boardColor: const Color(0xFFBDBDBD),
      emptyTileColor: const Color(0xFFD6D6D6),
      scoreTileColor: const Color(0xFF9E9E9E),
      textColor: const Color(0xFF212121),
    ),
    AppTheme(
      name: 'Rhino Grey',
      backgroundColor: const Color(0xFFECEFF1),
      boardColor: const Color(0xFF90A4AE),
      emptyTileColor: const Color(0xFFB0BEC5),
      scoreTileColor: const Color(0xFF78909C),
      textColor: const Color(0xFF37474F),
    ),
  ];
}
