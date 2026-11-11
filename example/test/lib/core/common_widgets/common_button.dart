import 'package:flutter/material.dart';
import '../theme_manager/app_colors.dart';

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.width,
    this.height = 48,
    this.borderRadius,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final double? width;
  final double height;
  final double? borderRadius;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final defaultBg = AppColors.primary(context);
    final defaultFg = Colors.white;
    final defaultDisabledBg = AppColors.disabled;
    final defaultDisabledFg = isDark ? Colors.black45 : Colors.white70;

    final theme = Theme.of(context);
    final baseStyle = theme.elevatedButtonTheme.style ?? const ButtonStyle();

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        style: baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return disabledBackgroundColor ?? defaultDisabledBg;
            }
            return backgroundColor ?? defaultBg;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return disabledForegroundColor ?? defaultDisabledFg;
            }
            return foregroundColor ?? defaultFg;
          }),
          shape: borderRadius != null
              ? WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius!),
                  ),
                )
              : null,
        ),
        onPressed: isEnabled && !isLoading ? onPressed : null,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    foregroundColor ?? defaultFg,
                  ),
                ),
              )
            : Text(label),
      ),
    );
  }
}
