import '../../state_management.dart';

class WidgetsTemplates {
  static String svgIcon() => '''
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme_manager/app_colors.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon(
    this.asset, {
    super.key,
    this.size = 24,
    this.color,
  });

  final String asset;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
''';

  static String commonLoader() => '''
import 'package:flutter/material.dart';
import '../theme_manager/app_colors.dart';

class CommonLoader extends StatelessWidget {
  final double? size;
  final Color? color;
  final double strokeWidth;
  final bool _isShimmer;

  // Shimmer configurable properties
  final double? width;
  final double? height;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final double? radius;
  final Color? shimmerColor;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final BoxShape shape;
  final Widget? child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  /// Default constructor for a CircularProgressIndicator loader.
  const CommonLoader({
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 4.0,
  })  : _isShimmer = false,
        width = null,
        height = null,
        border = null,
        borderRadius = null,
        radius = null,
        shimmerColor = null,
        baseColor = null,
        highlightColor = null,
        duration = const Duration(milliseconds: 1500),
        shape = BoxShape.rectangle,
        child = null,
        margin = null,
        padding = null;

  /// Shimmer loader constructor with customizable height, width, border, and shimmer color.
  const CommonLoader.shimmer({
    super.key,
    this.width,
    this.height,
    this.border,
    this.borderRadius,
    this.radius,
    this.shimmerColor,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.shape = BoxShape.rectangle,
    this.child,
    this.margin,
    this.padding,
  })  : _isShimmer = true,
        size = null,
        color = null,
        strokeWidth = 4.0;

  /// Shimmer loader for circular shapes (e.g., avatars).
  const CommonLoader.circularShimmer({
    super.key,
    required double size,
    this.border,
    this.shimmerColor,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.child,
    this.margin,
  })  : _isShimmer = true,
        width = size,
        height = size,
        borderRadius = null,
        radius = null,
        shape = BoxShape.circle,
        padding = null,
        size = null,
        color = null,
        strokeWidth = 4.0;

  @override
  Widget build(BuildContext context) {
    if (_isShimmer) {
      return CommonShimmer(
        width: width,
        height: height,
        border: border,
        borderRadius: borderRadius,
        radius: radius,
        shimmerColor: shimmerColor,
        baseColor: baseColor,
        highlightColor: highlightColor,
        duration: duration,
        shape: shape,
        margin: margin,
        padding: padding,
        child: child,
      );
    }

    final effectiveColor = color ?? AppColors.primary(context);
    final indicator = CircularProgressIndicator(
      strokeWidth: strokeWidth,
      valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
    );

    return Center(
      child: size != null
          ? SizedBox(
              width: size,
              height: size,
              child: indicator,
            )
          : indicator,
    );
  }
}

/// A pure Flutter custom shimmer widget built with standard animation and shader masks.
/// Requires NO external packages.
///
/// Supports customizable:
/// - [height] and [width]
/// - [border] and [borderRadius] / [radius]
/// - [shimmerColor], [baseColor], and [highlightColor]
/// - [duration] and [shape]
/// - Optional [child] widget to shimmer complex layouts
class CommonShimmer extends StatefulWidget {
  final double? width;
  final double? height;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final double? radius;
  final Color? shimmerColor;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final BoxShape shape;
  final Widget? child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const CommonShimmer({
    super.key,
    this.width,
    this.height,
    this.border,
    this.borderRadius,
    this.radius,
    this.shimmerColor,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.shape = BoxShape.rectangle,
    this.child,
    this.margin,
    this.padding,
  });

  /// Factory constructor for a circular shimmer placeholder (e.g., avatar).
  factory CommonShimmer.circular({
    Key? key,
    required double size,
    BoxBorder? border,
    Color? shimmerColor,
    Color? baseColor,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
    Widget? child,
    EdgeInsetsGeometry? margin,
  }) {
    return CommonShimmer(
      key: key,
      width: size,
      height: size,
      border: border,
      shape: BoxShape.circle,
      shimmerColor: shimmerColor,
      baseColor: baseColor,
      highlightColor: highlightColor,
      duration: duration,
      margin: margin,
      child: child,
    );
  }

  /// Factory constructor for a rectangular/rounded shimmer placeholder.
  factory CommonShimmer.rectangular({
    Key? key,
    double? width,
    double? height,
    BorderRadiusGeometry? borderRadius,
    double? radius,
    BoxBorder? border,
    Color? shimmerColor,
    Color? baseColor,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
    Widget? child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return CommonShimmer(
      key: key,
      width: width,
      height: height,
      borderRadius: borderRadius,
      radius: radius,
      border: border,
      shimmerColor: shimmerColor,
      baseColor: baseColor,
      highlightColor: highlightColor,
      duration: duration,
      margin: margin,
      padding: padding,
      child: child,
    );
  }

  @override
  State<CommonShimmer> createState() => _CommonShimmerState();
}

class _CommonShimmerState extends State<CommonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant CommonShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Default palette adapts seamlessly to dark and light modes
    final defaultBase =
        isDark ? const Color(0xFF232736) : const Color(0xFFE5E7EB);
    final defaultHighlight =
        isDark ? const Color(0xFF383E56) : const Color(0xFFF3F4F6);

    final effectiveBase = widget.baseColor ??
        (widget.shimmerColor != null
            ? widget.shimmerColor!.withValues(alpha: 0.35)
            : defaultBase);

    final effectiveHighlight =
        widget.highlightColor ?? (widget.shimmerColor ?? defaultHighlight);

    final effectiveRadius = widget.shape == BoxShape.circle
        ? null
        : (widget.borderRadius ??
            (widget.radius != null
                ? BorderRadius.circular(widget.radius!)
                : BorderRadius.circular(8.0)));

    final double? circleSize = widget.shape == BoxShape.circle
        ? (widget.width ?? widget.height ?? 40.0)
        : null;

    final effectiveWidth = circleSize ?? widget.width;
    final effectiveHeight = circleSize ?? widget.height;

    final Widget shimmerContent = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              stops: const [0.1, 0.5, 0.9],
              colors: [
                effectiveBase,
                effectiveHighlight,
                effectiveBase,
              ],
              transform: _SlidingGradientTransform(
                slidePercent: -1.5 + (3.0 * _controller.value),
              ),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child ??
          Container(
            width: effectiveWidth ?? double.infinity,
            height: effectiveHeight ?? 16.0,
            color: Colors.white,
          ),
    );

    // Apply clipping for rounded corners or circular bounds
    final Widget clippedContent;
    if (widget.shape == BoxShape.circle) {
      clippedContent = ClipOval(child: shimmerContent);
    } else if (effectiveRadius != null) {
      clippedContent = ClipRRect(
        borderRadius: effectiveRadius,
        child: shimmerContent,
      );
    } else {
      clippedContent = shimmerContent;
    }

    // Outer container handles borders, dimensions, margin, and padding
    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        border: widget.border,
        shape: widget.shape,
        borderRadius: effectiveRadius,
      ),
      child: clippedContent,
    );
  }
}

/// Helper gradient transform that slides horizontally across the target rect.
class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
''';

  static String commonButton() => '''
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
''';

  static String commonTextField() => '''
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
''';

  static String commonDropdown() => '''
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
''';

  static String commonCheckbox() => '''
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
''';

  static String commonSnackbar() => '''
import 'package:flutter/material.dart';
import '../theme_manager/app_colors.dart';

class CommonSnackbar {
  // Default background/text colors come from AppColors.primary(context) or AppTheme.
  // [backgroundColor]/[textColor] let a call site override just this one snackbar.
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
  }) {
    final effectiveBg = backgroundColor ?? AppColors.primary(context);
    final effectiveText = textColor ?? Colors.white;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: effectiveText),
        ),
        backgroundColor: effectiveBg,
        duration: duration,
      ),
    );
  }

  static void error(
    BuildContext context, {
    required String message,
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
    );
  }

  static void success(
    BuildContext context, {
    required String message,
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
    );
  }

  static void warning(
    BuildContext context, {
    required String message,
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.warning,
      textColor: Colors.white,
    );
  }

  static void info(
    BuildContext context, {
    required String message,
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.info,
      textColor: Colors.white,
    );
  }
}
''';

  static String commonAppBar() => '''
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
''';

  static String commonBottomSheet() => '''
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
''';

  static String commonDialog() => '''
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
''';

  static String commonImageContainer(StateManagement state) {
    const dimensionAccess = 'Dimensions';
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../theme_manager/app_colors.dart';
import '../theme_manager/dimensions.dart';
import '../utils/enums.dart';

class CommonImageContainer extends StatelessWidget {
  const CommonImageContainer._({
    super.key,
    required this.height,
    required this.width,
    required this.imageUrl,
    required this.sourceType,
    this.borderRadius = 0,
    this.isCircle = false,
    this.token = '',
    this.color,
    this.fit,
    this.clipBehavior,
    this.margin,
    this.padding,
    this.alignment,
    this.boxShadow,
    this.border,
    this.fallbackAssetPath,
  });

  factory CommonImageContainer.network({
    Key? key,
    required double height,
    required double width,
    required String imageUrl,
    String token = '',
    double borderRadius = 0,
    bool isCircle = false,
    String? fallbackAssetPath,
    BoxFit fit = BoxFit.cover,
    Color? color,
  }) {
    return CommonImageContainer._(
      key: key,
      height: height,
      width: width,
      imageUrl: imageUrl,
      token: token,
      sourceType: ImageSourceType.network,
      borderRadius: borderRadius,
      isCircle: isCircle,
      fallbackAssetPath: fallbackAssetPath,
      fit: fit,
      color: color,
    );
  }

  factory CommonImageContainer.offline({
    Key? key,
    required double height,
    required double width,
    required String assetPath,
    double borderRadius = 0,
    bool isCircle = false,
    BoxFit? fit,
    Color? color,
  }) {
    return CommonImageContainer._(
      key: key,
      height: height,
      width: width,
      imageUrl: assetPath,
      sourceType: ImageSourceType.offline,
      borderRadius: borderRadius,
      isCircle: isCircle,
      fit: fit,
      color: color,
    );
  }

  final double? height;
  final double? width;
  final double? borderRadius;
  final String? imageUrl;
  final bool isCircle;
  final String? token;
  final Color? color;
  final BoxFit? fit;
  final Clip? clipBehavior;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Alignment? alignment;
  final List<BoxShadow>? boxShadow;
  final BoxBorder? border;
  final String? fallbackAssetPath;
  final ImageSourceType sourceType;

  Widget _buildFallbackImage(BuildContext context) {
    if (fallbackAssetPath?.toLowerCase().endsWith('.svg') == true) {
      return Center(
        child: SvgPicture.asset(
          fallbackAssetPath ?? "",
          fit: BoxFit.contain,
          width: $dimensionAccess.width(40),
          height: $dimensionAccess.height(40),
        ),
      );
    } else {
      return Center(
        child: Image.asset(
          fallbackAssetPath ?? "",
          fit: BoxFit.contain,
          width: $dimensionAccess.width(40),
          height: $dimensionAccess.height(40),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBg = color ?? AppColors.surface(context);

    return Container(
      height: $dimensionAccess.height(height ?? 100),
      width: $dimensionAccess.width(width ?? 100),
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: effectiveBg,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            isCircle ? null : BorderRadius.circular($dimensionAccess.radius(borderRadius ?? 10)),
        border: border,
        boxShadow: boxShadow,
      ),
      clipBehavior: clipBehavior ?? Clip.hardEdge,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (sourceType == ImageSourceType.offline) {
      if (imageUrl?.toLowerCase().endsWith('.svg') == true) {
        return SvgPicture.asset(
          imageUrl ?? "",
          fit: fit ?? BoxFit.cover,
        );
      }
      return Image.asset(
        imageUrl ?? "",
        fit: fit,
      );
    }

    if (imageUrl?.isEmpty == true || imageUrl?.contains("default.png") == true) {
      return _buildFallbackImage(context);
    }

    return Image.network(
      imageUrl ?? "",
      fit: fit,
      headers: token?.isNotEmpty == true ? {"Authorization": "Bearer \$token"} : null,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: LinearProgressIndicator(
              color: AppColors.primary(context),
              backgroundColor: AppColors.border(context),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackImage(context);
      },
    );
  }
}
''';
  }

  static String paginatedListView() => '''
import 'package:flutter/material.dart';
import '../theme_manager/app_colors.dart';
import '../theme_manager/dimensions.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item, int index);
typedef SeparatorBuilder = Widget Function(BuildContext context, int index);
typedef LoadMoreCallback = void Function();

/// Pure-UI paginated list — state (items, loading, hasReachedMax) lives in
/// the caller's state management layer (BLoC / GetX / Riverpod / etc.).
class PaginatedListView<T> extends StatelessWidget {
  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.isLoading,
    required this.onLoadMore,
    this.hasReachedMax = false,
    this.scrollController,
    this.padding,
    this.reverse = false,
    this.primary,
    this.separatorBuilder,
    this.loadingWidget,
    this.emptyWidget,
    this.endWidget,
    this.loadThreshold = 0.8,
    this.showLoadingIndicator = true,
  });

  final List<T> items;
  final ItemBuilder<T> itemBuilder;
  final bool isLoading;
  final LoadMoreCallback onLoadMore;
  final bool hasReachedMax;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final bool reverse;
  final bool? primary;
  final SeparatorBuilder? separatorBuilder;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget? endWidget;
  final double loadThreshold;
  final bool showLoadingIndicator;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !isLoading && emptyWidget != null) {
      return emptyWidget!;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _handleScroll(notification);
        return false;
      },
      child: CustomScrollView(
        key: const PageStorageKey<String>('paginated_list'),
        controller: scrollController,
        reverse: reverse,
        primary: primary,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (padding != null) SliverPadding(padding: padding!),
          separatorBuilder != null ? _separatedList() : _normalList(),
          if (_bottomWidget(context) != null) _bottomWidget(context)!,
        ],
      ),
    );
  }

  Widget _normalList() => SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => itemBuilder(ctx, items[i], i),
          childCount: items.length,
          addRepaintBoundaries: true,
          addAutomaticKeepAlives: true,
        ),
      );

  Widget _separatedList() => SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (ctx, i) => separatorBuilder!(ctx, i),
        itemBuilder: (ctx, i) => itemBuilder(ctx, items[i], i),
      );

  Widget? _bottomWidget(BuildContext context) {
    if (isLoading && showLoadingIndicator) {
      return SliverToBoxAdapter(
        child: loadingWidget ??
            Padding(
              padding: Dimensions.allPadding(16),
              child: Center(
                child: SizedBox(
                  height: Dimensions.height(40),
                  width: Dimensions.width(40),
                  child: CircularProgressIndicator(
                    color: AppColors.primary(context),
                  ),
                ),
              ),
            ),
      );
    }
    if (hasReachedMax && endWidget != null && items.isNotEmpty) {
      return SliverToBoxAdapter(child: endWidget);
    }
    return null;
  }

  void _handleScroll(ScrollNotification notification) {
    if (isLoading || hasReachedMax || items.isEmpty) return;
    if (notification is ScrollUpdateNotification) {
      final m = notification.metrics;
      if (m.maxScrollExtent > 0 && m.pixels >= m.maxScrollExtent * loadThreshold) {
        onLoadMore();
      }
    }
    if (notification is ScrollEndNotification) {
      final m = notification.metrics;
      if (m.atEdge && m.pixels > 0) onLoadMore();
    }
  }
}
''';
}
