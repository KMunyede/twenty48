import 'package:flutter/material.dart';

Color readableTextOn(Color background) {
  final luminance = background.computeLuminance();
  return luminance > 0.5 ? Colors.black87 : Colors.white;
}
