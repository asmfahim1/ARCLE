import 'package:flutter/material.dart';
import '../theme_manager/app_colors.dart';

class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.maxLines = 1,
    this.minLines = 1,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.fillColor,
    this.textColor,
    this.hintColor,
    this.labelColor,
    this.borderColor,
    this.focusBorderColor,
    this.cursorColor,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  });

  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final int maxLines;
  final int minLines;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final Color? fillColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? labelColor;
  final Color? borderColor;
  final Color? focusBorderColor;
  final Color? cursorColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveFillColor = fillColor ?? AppColors.surface(context);
    final effectiveTextColor = textColor ?? AppColors.textPrimary(context);
    final effectiveHintColor = hintColor ?? AppColors.textSecondary(context);
    final effectiveBorderColor = borderColor ?? AppColors.border(context);
    final effectiveFocusBorderColor =
        focusBorderColor ?? AppColors.primary(context);

    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: effectiveTextColor),
      cursorColor: cursorColor ?? effectiveFocusBorderColor,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: effectiveHintColor),
        labelText: labelText,
        labelStyle: TextStyle(color: labelColor ?? effectiveHintColor),
        filled: true,
        fillColor: effectiveFillColor,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: effectiveBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: effectiveBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: effectiveFocusBorderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
