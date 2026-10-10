import 'package:flutter/material.dart';

Color getDialogTextColor(Color backgroundColor) {
  final isLight = ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.light;
  return isLight ? const Color(0xFF212121) : const Color(0xFFECEFF1);
}
