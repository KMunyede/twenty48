import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings/providers/theme_provider.dart';
import 'how_to_play_dialog.dart';

class HelpButton extends StatelessWidget {
  const HelpButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: theme.scoreTileColor.withValues(alpha: 0.2),
          foregroundColor: theme.textColor,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const HowToPlayDialog(),
        ),
        icon: const Text('?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        label: const Text('Help', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }
}
