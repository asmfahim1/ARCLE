import 'package:flutter/widgets.dart';

class Dimensions {
  final BuildContext context;

  static const double designWidth = 375.0;
  static const double designHeight = 812.0;

  Dimensions(this.context);

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;
  double get hRatio => screenHeight / designHeight;
  double get wRatio => screenWidth / designWidth;

  double height(double value) => value * hRatio;
  double width(double value) => value * wRatio;
  double font(double value) => value * wRatio;
  double icon(double value) => value * wRatio;

  EdgeInsets padding(double h, double v) =>
      EdgeInsets.symmetric(horizontal: width(h), vertical: height(v));

  EdgeInsets all(double value) => EdgeInsets.all(width(value));

  double radius(double value) => width(value);
}
