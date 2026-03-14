import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../utils/dimensions.dart';
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
    this.fallbackAssetPath,
    this.clipBehavior,
    this.margin,
    this.padding,
    this.alignment,
    this.boxShadow,
    this.border,
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
          width: Dimensions(context).width(40),
          height: Dimensions(context).height(40),
        ),
      );
    } else {
      return Center(
        child: Image.asset(
          fallbackAssetPath ?? "",
          fit: BoxFit.contain,
          width: Dimensions(context).width(40),
          height: Dimensions(context).height(40),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions(context).height(height ?? 100),
      width: Dimensions(context).width(width ?? 100),
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle
            ? null
            : BorderRadius.circular(
                Dimensions(context).radius(borderRadius ?? 10),
              ),
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
        return SvgPicture.asset(imageUrl ?? "", fit: fit ?? BoxFit.cover);
      }
      return Image.asset(imageUrl ?? "", fit: fit);
    }

    if (imageUrl?.isEmpty == true ||
        imageUrl?.contains("default.png") == true) {
      return _buildFallbackImage(context);
    }

    return Image.network(
      imageUrl ?? "",
      fit: fit,
      headers: token?.isNotEmpty == true
          ? {"Authorization": "Bearer $token"}
          : null,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: const LinearProgressIndicator(),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackImage(context);
      },
    );
  }
}
