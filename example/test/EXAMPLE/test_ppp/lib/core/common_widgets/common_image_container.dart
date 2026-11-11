import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../theme_manager/app_colors.dart';
import '../theme_manager/dimensions.dart';
import '../utils/enums.dart';

class CommonImageContainer extends StatelessWidget {
  const CommonImageContainer._({
    super.key,
    this.height,
    this.width,
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
    this.svgColor,
    this.fallbackText,
    this.fallbackTextColor,
  });

  factory CommonImageContainer.network({
    Key? key,
    double? height,
    double? width,
    required String imageUrl,
    String token = '',
    double borderRadius = 0,
    bool isCircle = false,
    String? fallbackAssetPath,
    String? fallbackText,
    Color? fallbackTextColor,
    BoxFit fit = BoxFit.cover,
    Color? color,
    BoxBorder? border,
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
      fallbackText: fallbackText,
      fallbackTextColor: fallbackTextColor,
      fit: fit,
      color: color,
      border: border,
    );
  }

  factory CommonImageContainer.offline({
    Key? key,
    double? height,
    double? width,
    EdgeInsets? padding,
    required String assetPath,
    double borderRadius = 0,
    bool isCircle = false,
    BoxFit? fit,
    Color? color,
    Color? svgColor,
  }) {
    return CommonImageContainer._(
      key: key,
      height: height,
      width: width,
      padding: padding,
      imageUrl: assetPath,
      sourceType: ImageSourceType.offline,
      borderRadius: borderRadius,
      isCircle: isCircle,
      fit: fit,
      color: color,
      svgColor: svgColor,
    );
  }

  final double? height;
  final double? width;
  final double? borderRadius;
  final String? imageUrl;
  final bool isCircle;
  final String? token;
  final Color? color;
  final Color? svgColor;
  final BoxFit? fit;
  final Clip? clipBehavior;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Alignment? alignment;
  final List<BoxShadow>? boxShadow;
  final BoxBorder? border;
  final String? fallbackAssetPath;
  final String? fallbackText;
  final Color? fallbackTextColor;
  final ImageSourceType sourceType;

  Widget _buildFallbackImage(BuildContext context) {
    if (fallbackText != null && fallbackText!.isNotEmpty) {
      final boxSize = height ?? width ?? 40;
      return Center(
        child: Text(
          fallbackText!,
          style: TextStyle(
            color: fallbackTextColor ?? AppColors.textPrimary(context),
            fontSize: Dimensions.font(boxSize * 0.38),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    if (fallbackAssetPath?.toLowerCase().endsWith('.svg') == true) {
      return Center(
        child: SvgPicture.asset(
          fallbackAssetPath ?? '',
          fit: BoxFit.contain,
          width: Dimensions.width(40),
          height: Dimensions.height(40),
        ),
      );
    } else {
      return Center(
        child: Image.asset(
          fallbackAssetPath ?? '',
          fit: BoxFit.contain,
          width: Dimensions.width(40),
          height: Dimensions.height(40),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBg = color ?? AppColors.surface(context);

    return Container(
      height: height != null ? Dimensions.height(height!) : null,
      width: width != null ? Dimensions.width(width!) : null,
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? EdgeInsets.zero,
      alignment: alignment,
      decoration: BoxDecoration(
        color: effectiveBg,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            isCircle
                ? null
                : BorderRadius.circular(Dimensions.radius(borderRadius ?? 10)),
        border: imageUrl?.isEmpty == true ? border : null,
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
          imageUrl ?? '',
          fit: fit ?? BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          colorFilter:
              svgColor != null
                  ? ColorFilter.mode(svgColor!, BlendMode.srcIn)
                  : null,
        );
      }
      return Image.asset(
        imageUrl ?? '',
        fit: fit ?? BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (imageUrl?.isEmpty == true ||
        imageUrl?.contains('default.png') == true) {
      return _buildFallbackImage(context);
    }

    return Image.network(
      imageUrl ?? '',
      fit: fit ?? BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      headers:
          token?.isNotEmpty == true ? {'Authorization': 'Bearer $token'} : null,
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
