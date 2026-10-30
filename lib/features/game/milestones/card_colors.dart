// lib/features/game/milestones/card_colors.dart

import 'dart:math';
import 'dart:ui';

/// Calculates the WCAG 2.0 relative luminance contrast ratio between two colors.
/// Formula: (L1 + 0.05) / (L2 + 0.05) where L1 is the lighter luminance.
double contrastRatio(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

/// Moves [color] lighter or darker in small steps (preserving its hue)
/// until [contrastRatio(adjusted, against)] >= [minRatio].
/// If the ratio cannot be met, returns pure black or pure white
/// (whichever provides higher contrast against [against]).
Color ensureContrast(Color color, Color against, double minRatio) {
  if (contrastRatio(color, against) >= minRatio) {
    return color;
  }

  final hsl = _HSL.fromColor(color);
  final lColor = color.computeLuminance();
  final lAgainst = against.computeLuminance();

  // Determine primary direction.
  // If color is lighter than or equal to against, lighter increases contrast.
  // If color is darker than against, darker increases contrast.
  bool primaryIsLighter = lColor > lAgainst;
  if (lColor == lAgainst) {
    final maxLighter = contrastRatio(const Color(0xFFFFFFFF), against);
    final maxDarker = contrastRatio(const Color(0xFF000000), against);
    primaryIsLighter = maxLighter >= maxDarker;
  }

  // Helper to step in a given direction
  Color? tryDirection(bool lighter) {
    double currentL = hsl.l;
    final step = lighter ? 0.01 : -0.01;
    final targetLimit = lighter ? 1.0 : 0.0;

    while ((lighter && currentL < targetLimit) ||
        (!lighter && currentL > targetLimit)) {
      currentL += step;
      if (lighter && currentL > 1.0) currentL = 1.0;
      if (!lighter && currentL < 0.0) currentL = 0.0;

      final candidate = hsl.withL(currentL).toColor();
      if (contrastRatio(candidate, against) >= minRatio) {
        return candidate;
      }
    }
    return null;
  }

  // Try primary direction first
  final primaryResult = tryDirection(primaryIsLighter);
  if (primaryResult != null) {
    return primaryResult;
  }

  // Try secondary direction
  final secondaryResult = tryDirection(!primaryIsLighter);
  if (secondaryResult != null) {
    return secondaryResult;
  }

  // Fallback to white or black based on higher contrast against `against`
  final contrastWhite = contrastRatio(const Color(0xFFFFFFFF), against);
  final contrastBlack = contrastRatio(const Color(0xFF000000), against);
  return contrastWhite >= contrastBlack
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF000000);
}

class _HSL {
  final double h; // 0..360
  final double s; // 0..1
  final double l; // 0..1
  final int alpha; // 0..255

  _HSL(this.h, this.s, this.l, [this.alpha = 255]);

  _HSL withL(double newL) => _HSL(h, s, newL.clamp(0.0, 1.0), alpha);

  static _HSL fromColor(Color c) {
    final r = (c.r * 255.0).round().clamp(0, 255) / 255.0;
    final g = (c.g * 255.0).round().clamp(0, 255) / 255.0;
    final b = (c.b * 255.0).round().clamp(0, 255) / 255.0;

    final maxVal = max(r, max(g, b));
    final minVal = min(r, min(g, b));
    final delta = maxVal - minVal;

    final l = (maxVal + minVal) / 2.0;

    double h = 0.0;
    double s = 0.0;

    if (delta != 0.0) {
      s = l > 0.5 ? delta / (2.0 - maxVal - minVal) : delta / (maxVal + minVal);

      if (maxVal == r) {
        h = (g - b) / delta + (g < b ? 6.0 : 0.0);
      } else if (maxVal == g) {
        h = (b - r) / delta + 2.0;
      } else {
        h = (r - g) / delta + 4.0;
      }
      h /= 6.0;
      h *= 360.0;
    }

    final a = (c.a * 255.0).round().clamp(0, 255);
    return _HSL(h, s, l, a);
  }

  Color toColor() {
    if (s == 0.0) {
      final val = (l * 255.0).round().clamp(0, 255);
      return Color.fromARGB(alpha, val, val, val);
    }

    double hue2rgb(double p, double q, double t) {
      if (t < 0.0) t += 1.0;
      if (t > 1.0) t -= 1.0;
      if (t < 1 / 6) return p + (q - p) * 6.0 * t;
      if (t < 1 / 2) return q;
      if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6.0;
      return p;
    }

    final q = l < 0.5 ? l * (1.0 + s) : l + s - l * s;
    final p = 2.0 * l - q;
    final hk = h / 360.0;

    final r = (hue2rgb(p, q, hk + 1 / 3) * 255.0).round().clamp(0, 255);
    final g = (hue2rgb(p, q, hk) * 255.0).round().clamp(0, 255);
    final b = (hue2rgb(p, q, hk - 1 / 3) * 255.0).round().clamp(0, 255);

    return Color.fromARGB(alpha, r, g, b);
  }
}
