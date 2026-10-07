import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common_widgets/common_button.dart';
import '../../../../core/common_widgets/common_text_field.dart';
import '../../../../core/route_handler/app_routes.dart';
import '../../../../core/utils/dialogs.dart';
import '../../../../core/utils/dimensions.dart';
import '../controller/auth_controller.dart';

/// Login form widget for GetX state management.
class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'login_hint'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: Dimensions.height(16)),
            CommonTextField(
              labelText: 'email'.tr,
              keyboardType: TextInputType.emailAddress,
              onChanged: controller.setEmail,
            ),
            SizedBox(height: Dimensions.height(12)),
            CommonTextField(
              labelText: 'password'.tr,
              obscureText: true,
              onChanged: controller.setPassword,
            ),
            SizedBox(height: Dimensions.height(20)),
            CommonButton(
              label: 'login'.tr,
              isLoading: controller.status.value == AuthStatus.loading,
              onPressed: () => controller.login(
                controller.email.value,
                controller.password.value,
                onSuccess: () => Get.offNamed(AppRoutes.users),
                onFailure: AppDialogs.showError,
              ),
            ),
          ],
        ));
  }
}
