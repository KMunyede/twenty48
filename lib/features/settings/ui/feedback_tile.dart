// lib/features/settings/ui/feedback_tile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:twenty48/features/settings/providers/theme_provider.dart';

class FeedbackTile extends StatelessWidget {
  const FeedbackTile({super.key});

  Future<void> _sendFeedback(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@hilmost.net',
      queryParameters: {
        'subject': '2048 GrandMasters feedback',
      },
    );
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No email app found. Write to support@hilmost.net'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No email app found. Write to support@hilmost.net'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return ListTile(
      leading: Icon(Icons.mail, color: theme.textColor),
      title: Text('Send feedback', style: TextStyle(color: theme.textColor)),
      subtitle: Text(
        'Tell us what to improve',
        style: TextStyle(color: theme.textColor.withValues(alpha: 0.7)),
      ),
      onTap: () => _sendFeedback(context),
    );
  }
}
