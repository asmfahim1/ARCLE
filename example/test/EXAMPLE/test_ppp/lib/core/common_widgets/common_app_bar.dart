import 'package:flutter/material.dart';
import '../theme_manager/app_colors.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.iconColor,
    this.titleStyle,
    this.showBackButton = true,
  });

  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? iconColor;
  final TextStyle? titleStyle;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.surface(context);
    final effectiveFg = foregroundColor ?? AppColors.textPrimary(context);
    final effectiveIconColor = iconColor ?? effectiveFg;

    return AppBar(
      title: Text(
        title,
        style: titleStyle ??
            TextStyle(color: effectiveFg, fontWeight: FontWeight.w600),
      ),
      backgroundColor: effectiveBg,
      foregroundColor: effectiveFg,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: effectiveIconColor),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
