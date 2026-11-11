import 'package:flutter/material.dart';
import '../theme_manager/app_colors.dart';

class CommonBottomSheet extends StatelessWidget {
  const CommonBottomSheet({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.backgroundColor,
    this.titleColor,
    this.titleStyle,
    this.height,
  });

  final String title;
  final Widget content;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? titleColor;
  final TextStyle? titleStyle;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.surface(context);
    final effectiveTitleColor = titleColor ?? AppColors.textPrimary(context);

    return Container(
      height: height ?? 300,
      decoration: BoxDecoration(
        color: effectiveBg,
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
              style: titleStyle ??
                  Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: effectiveTitleColor,
                      ) ??
                  TextStyle(
                    color: effectiveTitleColor,
                    fontWeight: FontWeight.w600,
                  ),
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
