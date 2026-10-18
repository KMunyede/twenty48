import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings/providers/theme_provider.dart';
import 'how_to_play_dialog.dart';

class HowToPlayTile extends StatelessWidget {
  const HowToPlayTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return ListTile(
      leading: Icon(Icons.help_outline, color: theme.textColor),
      title: Text('How to play', style: TextStyle(color: theme.textColor)),
      subtitle: Text(
        'Quick guide',
        style: TextStyle(color: theme.textColor.withValues(alpha: 0.7)),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const HowToPlayDialog(),
        );
      },
    );
  }
}
