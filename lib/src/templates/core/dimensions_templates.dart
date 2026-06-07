class DimensionsTemplates {
  static String dimensions() => r'''
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

class Dimensions {
  static double get _screenHeight =>
      ui.PlatformDispatcher.instance.views.first.physicalSize.height /
      ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
  static double get _screenWidth =>
      ui.PlatformDispatcher.instance.views.first.physicalSize.width /
      ui.PlatformDispatcher.instance.views.first.devicePixelRatio;

  // Base design size from Figma (iPhone SE or similar mobile design)
  static const double _mockupHeight = 884.0;
  static const double _mockupWidth = 390.0;

  // Scale factors for responsive design
  static double get _heightRatio => _screenHeight / _mockupHeight;
  static double get _widthRatio => _screenWidth / _mockupWidth;

  // Font scaling
  static double get _fontRatio => (_widthRatio + _heightRatio) / 2;

  /// Use for vertical values like height, vertical padding/margin
  static double height(double value) => value * _heightRatio;

  /// Use for horizontal values like width, horizontal padding/margin
  static double width(double value) => value * _widthRatio;

  /// Use for font sizes
  static double font(double value) => value * _fontRatio;

  /// Use for border radius
  static double radius(double value) => value * _widthRatio;

  /// Use for icon sizes
  static double icon(double value) => value * _widthRatio;

  /// Use for border width
  static double border(double value) => value * _widthRatio;

  /// EdgeInsets helpers
  static EdgeInsets allPadding(double padding) => EdgeInsets.all(width(padding));
  static EdgeInsets paddingHorizontal(double horizontal) =>
      EdgeInsets.symmetric(horizontal: width(horizontal));
  static EdgeInsets paddingVertical(double vertical) =>
      EdgeInsets.symmetric(vertical: height(vertical));
  static EdgeInsets paddingTop(double top) => EdgeInsets.only(top: height(top));
  static EdgeInsets paddingBottom(double bottom) => EdgeInsets.only(bottom: height(bottom));
  static EdgeInsets paddingLeft(double left) => EdgeInsets.only(left: width(left));
  static EdgeInsets paddingRight(double right) => EdgeInsets.only(right: width(right));
  static EdgeInsets paddingSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) =>
      EdgeInsets.symmetric(
        horizontal: width(horizontal),
        vertical: height(vertical),
      );
  static EdgeInsets paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(
        left: width(left),
        top: height(top),
        right: width(right),
        bottom: height(bottom),
      );

  /// Margin helpers
  static EdgeInsets marginAll(double margin) => EdgeInsets.all(width(margin));
  static EdgeInsets marginHorizontal(double horizontal) =>
      EdgeInsets.symmetric(horizontal: width(horizontal));
  static EdgeInsets marginVertical(double vertical) =>
      EdgeInsets.symmetric(vertical: height(vertical));
  static EdgeInsets marginTop(double top) => EdgeInsets.only(top: height(top));
  static EdgeInsets marginBottom(double bottom) => EdgeInsets.only(bottom: height(bottom));
  static EdgeInsets marginLeft(double left) => EdgeInsets.only(left: width(left));
  static EdgeInsets marginRight(double right) => EdgeInsets.only(right: width(right));
  static EdgeInsets marginSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) =>
      EdgeInsets.symmetric(
        horizontal: width(horizontal),
        vertical: height(vertical),
      );
  static EdgeInsets marginOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(
        left: width(left),
        top: height(top),
        right: width(right),
        bottom: height(bottom),
      );
}
''';
}
