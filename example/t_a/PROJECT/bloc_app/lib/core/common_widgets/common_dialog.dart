import 'package:flutter/material.dart';

class CommonDialog extends StatelessWidget {
  const CommonDialog({
    super.key,
    required this.title,
    required this.message,
    this.actions,
    this.backgroundColor,
    this.icon,
  });

  final String title;
  final String message;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backgroundColor,
      icon: icon != null ? Icon(icon) : null,
      title: Text(title),
      content: Text(message),
      actions: actions ??
          [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
    );
  }
}
