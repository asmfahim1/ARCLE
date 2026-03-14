import 'package:flutter/material.dart';

class CommonCheckbox extends StatelessWidget {
  const CommonCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.activeColor,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final String? label;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor ?? Colors.blue,
        ),
        if (label != null)
          Expanded(
            child: Text(label!),
          ),
      ],
    );
  }
}
