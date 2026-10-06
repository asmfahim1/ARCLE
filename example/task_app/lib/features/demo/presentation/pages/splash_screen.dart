import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/route_handler/app_routes.dart';
import '../../../../core/session_manager/session_manager.dart';

/// Splash screen for BLoC state management.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _route(BuildContext context) async {
    final session = getIt<SessionManager>();
    final isLoggedIn = session.isAuthenticated;
    final target = isLoggedIn ? AppRoutes.users : AppRoutes.login;
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, target);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _route(context));
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
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
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preparing your workspace...',
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
