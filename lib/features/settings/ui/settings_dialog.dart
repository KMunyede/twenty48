// lib/features/settings/ui/settings_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_theme.dart';
import '../providers/theme_provider.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Color Theme:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...AppTheme.themes.map((theme) {
              return RadioListTile<AppTheme>(
                title: Text(theme.name),
                value: theme,
                groupValue: context.watch<ThemeProvider>().currentTheme,
                onChanged: (value) {
                  if (value != null) {
                    context.read<ThemeProvider>().setTheme(value);
                  }
                },
                secondary: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.boardColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
