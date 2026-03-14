import 'package:flutter/material.dart';

class CommonDropdown<T> extends StatelessWidget {
  const CommonDropdown({
    super.key,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.hint,
  });

  final List<T> items;
  final T? value;
  final String Function(T) itemLabel;
  final Function(T?) onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: value,
      hint: Text(hint ?? 'Select'),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
