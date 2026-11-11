import 'package:flutter/material.dart';
import '../theme_manager/app_colors.dart';

class CommonDropdown<T> extends StatelessWidget {
  const CommonDropdown({
    super.key,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.hint,
    this.labelText,
    this.validator,
    this.fillColor,
    this.dropdownColor,
    this.textColor,
    this.hintColor,
    this.borderColor,
    this.focusBorderColor,
    this.iconColor,
  });

  final List<T> items;
  final T? value;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final String? labelText;
  final String? Function(T?)? validator;
  final Color? fillColor;
  final Color? dropdownColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? borderColor;
  final Color? focusBorderColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final effectiveFillColor = fillColor ?? AppColors.surface(context);
    final effectiveDropdownColor = dropdownColor ?? AppColors.surface(context);
    final effectiveTextColor = textColor ?? AppColors.textPrimary(context);
    final effectiveHintColor = hintColor ?? AppColors.textSecondary(context);
    final effectiveBorderColor = borderColor ?? AppColors.border(context);
    final effectiveFocusBorderColor =
        focusBorderColor ?? AppColors.primary(context);
    final effectiveIconColor = iconColor ?? AppColors.textSecondary(context);

    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      dropdownColor: effectiveDropdownColor,
      iconEnabledColor: effectiveIconColor,
      style: TextStyle(color: effectiveTextColor),
      decoration: InputDecoration(
        hintText: hint ?? 'Select',
        hintStyle: TextStyle(color: effectiveHintColor),
        labelText: labelText,
        labelStyle: TextStyle(color: effectiveHintColor),
        filled: true,
        fillColor: effectiveFillColor,
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
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabel(item),
            style: TextStyle(color: effectiveTextColor),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
