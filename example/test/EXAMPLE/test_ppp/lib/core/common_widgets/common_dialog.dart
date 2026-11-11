import 'package:flutter/material.dart';
import '../theme_manager/app_colors.dart';

class CommonDialog extends StatelessWidget {
  const CommonDialog({
    super.key,
    required this.title,
    required this.message,
    this.actions,
    this.backgroundColor,
    this.titleColor,
    this.messageColor,
    this.iconColor,
    this.icon,
  });

  final String title;
  final String message;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? messageColor;
  final Color? iconColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.surface(context);
    final effectiveTitleColor = titleColor ?? AppColors.textPrimary(context);
    final effectiveMsgColor = messageColor ?? AppColors.textSecondary(context);
    final effectiveIconColor = iconColor ?? AppColors.primary(context);

    return AlertDialog(
      backgroundColor: effectiveBg,
      icon: icon != null ? Icon(icon, color: effectiveIconColor) : null,
      title: Text(
        title,
        style: TextStyle(
          color: effectiveTitleColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(color: effectiveMsgColor),
      ),
      actions: actions ??
          [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(color: AppColors.primary(context)),
              ),
            ),
          ],
    );
  }
}
