import 'package:get/get.dart';

class Language extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'welcome': 'Welcome',
          'login_title': 'Login',
          'login_hint': 'Use your demo credentials to continue.',
          'email': 'Email',
          'password': 'Password',
          'login': 'Login',
          'settings': 'Settings',
          'user_list': 'User List',
          'retry': 'Retry',
          'theme': 'Theme',
          'dark_mode': 'Dark mode',
          'language': 'Language',
          // arcle:keys_en
        },
        'bn_BD': {
          'welcome': 'সবগতম',
          'login_title': 'লগইন',
          'login_hint': 'ডেমো ক্রেডেনশিয়াল দিয়ে চালিয়ে যান।',
          'email': 'ইমেইল',
          'password': 'পাসওয়ার্ড',
          'login': 'লগইন',
          'settings': 'সেটিংস',
          'user_list': 'ইউজার লিস্ট',
          'retry': 'আবার চেষ্টা করুন',
          'theme': 'থিম',
          'dark_mode': 'ডার্ক মোড',
          'language': 'ভাষা',
          // arcle:keys_bn
        },
      };
}
