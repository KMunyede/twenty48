// lib/features/settings/ui/settings_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_theme.dart';
import '../providers/theme_provider.dart';
import '../../game/providers/game_provider.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      backgroundColor: theme.backgroundColor,
      // Setting insetPadding to zero allows the dialog to grow as wide as the constraints allow
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390), // Force 390px width
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Game Mode:', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textColor)),
                          const SizedBox(height: 8),
                          _buildModeTile(
                            context,
                            'Normal Mode',
                            'Standard 2048 gameplay',
                            Icons.videogame_asset,
                            () => context.read<GameProvider>().setStandardMode(),
                          ),
                          _buildModeTile(
                            context,
                            'Challenge: 1024',
                            '300s to reach 1024',
                            Icons.timer,
                            () => context.read<GameProvider>().startTimerChallenge(1024),
                          ),
                          _buildModeTile(
                            context,
                            'Challenge: 2048',
                            '360s to reach 2048',
                            Icons.timer,
                            () => context.read<GameProvider>().startTimerChallenge(2048),
                          ),
                          const Divider(),
                          Text('Choose Color Theme:', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textColor)),
                          const SizedBox(height: 8),
                          RadioGroup<AppTheme>(
                            groupValue: theme,
                            onChanged: (value) {
                              if (value != null) {
                                context.read<ThemeProvider>().setTheme(value);
                              }
                            },
                            child: Column(
                              children: AppTheme.themes.map((appTheme) {
                                return RadioListTile<AppTheme>(
                                  title: Text(appTheme.name, style: TextStyle(color: theme.textColor)),
                                  value: appTheme,
                                  secondary: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: appTheme.boardColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close', style: TextStyle(color: theme.textColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeTile(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    return ListTile(
      title: Text(title, style: TextStyle(color: theme.textColor)),
      subtitle: Text(subtitle, style: TextStyle(color: theme.textColor.withValues(alpha: 0.7))),
      onTap: () {
        onTap();
        Navigator.of(context).pop();
      },
      leading: Icon(icon, color: theme.textColor),
    );
  }
}
