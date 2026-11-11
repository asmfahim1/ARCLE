import 'package:flutter/material.dart';
import '../theme_manager/app_colors.dart';

class CommonCheckbox extends StatelessWidget {
  const CommonCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.activeColor,
    this.checkColor,
    this.borderColor,
    this.textColor,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final String? label;
  final Color? activeColor;
  final Color? checkColor;
  final Color? borderColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primary(context);
    final effectiveCheckColor = checkColor ??
        (AppColors.isDark(context) ? Colors.black : Colors.white);
    final effectiveBorderColor = borderColor ?? AppColors.border(context);
    final effectiveTextColor = textColor ?? AppColors.textPrimary(context);

    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: effectiveActiveColor,
          checkColor: effectiveCheckColor,
          side: BorderSide(color: effectiveBorderColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        if (label != null)
          Expanded(
            child: Text(
              label!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: effectiveTextColor,
                      ) ??
                  TextStyle(color: effectiveTextColor),
            ),
          ),
      ],
    );
  }
}
