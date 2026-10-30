import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../settings/providers/theme_provider.dart';
import 'card_colors.dart';
import 'milestone_ladder.dart';

class MilestoneCelebrationCard extends StatefulWidget {
  static const Duration autoDismissDuration = Duration(seconds: 20);

  final Milestone milestone;
  final VoidCallback onDismiss;

  const MilestoneCelebrationCard({
    super.key,
    required this.milestone,
    required this.onDismiss,
  });

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
    final screenBg = theme.backgroundColor;
    final isDark = screenBg.computeLuminance() < 0.5;

    final cardSurface = Color.alphaBlend(
      const Color(0xFFFFFFFF).withValues(alpha: isDark ? 0.12 : 0.55),
      screenBg,
    );

    final borderColor = ensureContrast(theme.boardColor, screenBg, 3.0);

    final startTrophyColor =
        isDark ? const Color(0xFFFFA726) : const Color(0xFFE65100);
    final trophyColor = ensureContrast(startTrophyColor, cardSurface, 3.0);

    final textColor = ensureContrast(theme.textColor, cardSurface, 4.5);

    final startButtonFill =
        isDark ? const Color(0xFFFFA726) : const Color(0xFFE65100);
    final buttonFill = ensureContrast(startButtonFill, cardSurface, 3.0);

    final okLabelColor =
        ensureContrast(const Color(0xFFFFFFFF), buttonFill, 4.5);

    return Card(
      elevation: 12,
      shadowColor: Colors.black38,
      color: cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: borderColor,
          width: 3.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: trophyColor,
                  size: 40,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.milestone.value}',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.milestone.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '"${widget.milestone.hype}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: buttonFill,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: widget.onDismiss,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: okLabelColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
