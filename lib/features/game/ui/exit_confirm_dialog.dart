import 'package:flutter/material.dart';

class ExitConfirmDialog extends StatelessWidget {
  const ExitConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exit game?'),
      content: const Text('Are you sure you want to exit 2048 GrandMasters?'),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFE65100),
          ),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Stay'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE65100),
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Exit'),
        ),
      ],
    );
  }
}
