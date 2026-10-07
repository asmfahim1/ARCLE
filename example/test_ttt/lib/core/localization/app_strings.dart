import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AppStrings {
  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('bn', 'BD'),
  ];
}

extension AppLocalizationX on BuildContext {
  String tr(String key) => key.tr;
}
