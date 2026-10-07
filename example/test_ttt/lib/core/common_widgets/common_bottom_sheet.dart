import 'package:flutter/material.dart';

class CommonBottomSheet extends StatelessWidget {
  const CommonBottomSheet({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.backgroundColor,
    this.height,
  });

  final String title;
  final Widget content;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 300,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: content,
              ),
            ),
          ),
          if (actions != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: actions!,
              ),
            ),
        ],
      ),
    );
  }
}
