import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'stats_dialog.dart';

class StatsTile extends StatelessWidget {
  const StatsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return ListTile(
      leading: Icon(Icons.bar_chart, color: theme.textColor),
      title: Text('Your stats', style: TextStyle(color: theme.textColor)),
      subtitle: Text(
        'Games, milestones and streaks',
        style: TextStyle(color: theme.textColor.withValues(alpha: 0.7)),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const StatsDialog(),
        );
      },
    );
  }
}
