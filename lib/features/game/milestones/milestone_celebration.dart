import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../settings/models/app_theme.dart';
import '../../settings/providers/theme_provider.dart';
import 'milestone_ladder.dart';

class MilestoneCelebrationCard extends StatefulWidget {
  static const Duration autoDismissDuration = Duration(seconds: 6);

  final Milestone milestone;
  final VoidCallback onDismiss;

  const MilestoneCelebrationCard({
    super.key,
    required this.milestone,
    required this.onDismiss,
  });

  static Color getCardTextColor(AppTheme theme) {
    switch (theme.name) {
      case 'Turtle green':
        return const Color(0xFF0F380F);
      case 'Sunset Orange':
        return const Color(0xFF3E2723);
      case 'Oceanic Blue':
        return const Color(0xFF003B6B);
      case 'Rare Indigo':
      case 'Arctic White':
      case 'Rhino Grey':
      default:
        return theme.textColor;
    }
  }

  static Color getCardHypeColor(AppTheme theme) {
    final textColor = getCardTextColor(theme);
    if (theme.name == 'Rhino Grey') {
      return textColor.withValues(alpha: 0.85);
    }
    return textColor.withValues(alpha: 0.90);
  }

  @override
  State<MilestoneCelebrationCard> createState() =>
      _MilestoneCelebrationCardState();
}

class _MilestoneCelebrationCardState extends State<MilestoneCelebrationCard> {
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant MilestoneCelebrationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.milestone.value != widget.milestone.value) {
      _dismissTimer?.cancel();
      _startTimer();
    }
  }

  void _startTimer() {
    _dismissTimer = Timer(MilestoneCelebrationCard.autoDismissDuration, () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final headingColor = MilestoneCelebrationCard.getCardTextColor(theme);
    final hypeColor = MilestoneCelebrationCard.getCardHypeColor(theme);

    return GestureDetector(
      onTap: widget.onDismiss,
      child: Card(
        elevation: 6,
        shadowColor: Colors.black38,
        color: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.boardColor,
            width: 2.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Stack(
            children: [
              const Positioned(
                left: 0,
                top: 0,
                child: Icon(
                  Icons.emoji_events,
                  color: Color(0xFFFFC107), // Amber/gold
                  size: 20,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.milestone.value}',
                      style: TextStyle(
                        color: headingColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.milestone.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: headingColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"${widget.milestone.hype}"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: hypeColor,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
