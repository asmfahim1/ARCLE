import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/route_handler/app_routes.dart';
import '../../../../core/session_manager/session_manager.dart';

/// Splash screen for GetX state management.
/// 
/// Uses GetX navigation (Get.offNamed) for routing.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _route() async {
    final session = Get.find<SessionManager>();
    final isLoggedIn = await session.isAuthenticated;
    final target = isLoggedIn ? AppRoutes.users : AppRoutes.login;
    // Use GetX navigation instead of Navigator
    Get.offNamed(target);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Container(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.blur_on,
                    size: 48,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to Arcle',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Loading your session...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
