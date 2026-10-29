import 'dart:async';
import 'package:flutter/material.dart';
import 'milestone_ladder.dart';

class MilestoneCelebrationCard extends StatefulWidget {
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
    _dismissTimer = Timer(const Duration(seconds: 4), () {
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
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Card(
        elevation: 8,
        color: const Color(0xFFD84315), // Deep Orange
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFFFF8A65), // Lighter deep orange border
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.milestone.value}',
                style: const TextStyle(
                  color: Color(0xFFFFCCBC),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.milestone.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '"${widget.milestone.hype}"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
