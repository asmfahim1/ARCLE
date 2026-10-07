import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common_widgets/common_app_bar.dart';
import '../../../../core/common_widgets/common_button.dart';
import '../../../../core/common_widgets/common_loader.dart';
import '../../../../core/route_handler/app_routes.dart';
import '../../../../core/utils/dialogs.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/session_manager/session_manager.dart';
import '../controller/auth_controller.dart';
import '../controller/users_controller.dart';
import '../widgets/user_card.dart';

/// Users list screen for GetX state management.
/// 
/// Uses GetX for navigation, dialogs, bottom sheets, and reactive state.
class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usersController = Get.find<UsersController>();
    final authController = Get.find<AuthController>();
    
    return Scaffold(
      appBar: CommonAppBar(
        title: 'user_list'.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: usersController.load,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(authController),
          ),
        ],
      ),
      body: Obx(() {
        if (usersController.loading.value) {
          return const CommonLoader();
        }
        
        if (usersController.error.value != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Get.theme.colorScheme.error,
                ),
                SizedBox(height: Dimensions.height(16)),
                Text(usersController.error.value ?? 'Error'),
                SizedBox(height: Dimensions.height(12)),
                CommonButton(
                  label: 'retry'.tr,
                  onPressed: usersController.load,
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: Dimensions.allPadding(16),
          itemCount: usersController.users.length,
          itemBuilder: (_, index) => UserCard(user: usersController.users[index]),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSessionInfo,
        child: const Icon(Icons.info_outline),
      ),
    );
  }

  /// Shows logout confirmation using GetX dialog.
  void _showLogoutConfirmation(AuthController authController) async {
    final confirmed = await AppDialogs.showConfirm(
      title: 'logout'.tr,
      message: 'logout_confirm'.tr,
      confirmText: 'logout'.tr,
      cancelText: 'cancel'.tr,
    );
    if (!confirmed) return;
    await authController.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  /// Shows session info using GetX bottom sheet.
  void _showSessionInfo() async {
    final session = Get.find<SessionManager>();
    final token = await session.getToken() ?? 'No token';
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'session_info'.tr,
              style: Get.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Token:',
              style: Get.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                token,
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Get.back(),
                child: Text('close'.tr),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
