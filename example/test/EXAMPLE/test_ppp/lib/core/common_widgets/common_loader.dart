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
