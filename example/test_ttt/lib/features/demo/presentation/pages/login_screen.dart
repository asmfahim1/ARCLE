import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common_widgets/common_app_bar.dart';
import '../../../../core/route_handler/app_routes.dart';
import '../../../../core/utils/dimensions.dart';
import '../widgets/login_form.dart';

/// Login screen for GetX state management.
/// 
/// Uses GetX for navigation, dialogs, snackbars, and reactive state.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'login_title'.tr,
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: Dimensions.allPadding(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LoginForm(),
            SizedBox(height: Dimensions.height(12)),
            OutlinedButton(
              onPressed: () => Get.toNamed(AppRoutes.settings),
              child: Text('settings'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
