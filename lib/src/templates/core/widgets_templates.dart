import '../../state_management.dart';

class WidgetsTemplates {
  static String svgIcon() => '''
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon(this.asset, {super.key, this.size = 24});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
    );
  }
}
''';

  static String commonLoader() => '''
import 'package:flutter/material.dart';

class CommonLoader extends StatelessWidget {
  const CommonLoader({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(),
      );
}
''';

  static String commonButton() => '''
import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.width,
    this.height = 48,
    this.borderRadius = 8,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isEnabled ? backgroundColor ?? Colors.blue : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: isEnabled && !isLoading ? onPressed : null,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
''';

  static String commonTextField() => '''
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
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
''';

  static String commonCheckbox() => '''
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
''';

  static String commonSnackbar() => '''
import 'package:flutter/material.dart';

class CommonSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? Colors.white),
        ),
        backgroundColor: backgroundColor ?? Colors.grey[800],
        duration: duration,
      ),
    );
  }

  static void error(
    BuildContext context, {
    required String message,
  }) {
    show(context, message: message, backgroundColor: Colors.red);
  }

  static void success(
    BuildContext context, {
    required String message,
  }) {
    show(context, message: message, backgroundColor: Colors.green);
  }
}
''';

  static String commonAppBar() => '''
import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.titleStyle,
    this.showBackButton = true,
  });

  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final TextStyle? titleStyle;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: titleStyle ??
            const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
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
''';

  static String commonDialog() => '''
import 'package:flutter/material.dart';

class CommonDialog extends StatelessWidget {
  const CommonDialog({
    super.key,
    required this.title,
    required this.message,
    this.actions,
    this.backgroundColor,
    this.icon,
  });

  final String title;
  final String message;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backgroundColor,
      icon: icon != null ? Icon(icon) : null,
      title: Text(title),
      content: Text(message),
      actions: actions ??
          [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
    );
  }
}
''';

  static String commonImageContainer(StateManagement state) {
    final dimensionAccess =
        state == StateManagement.getx ? 'Dimensions' : 'Dimensions(context)';
    return '''
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
    return Container(
      height: $dimensionAccess.height(height ?? 100),
      width: $dimensionAccess.width(width ?? 100),
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
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
''';
  }
}
