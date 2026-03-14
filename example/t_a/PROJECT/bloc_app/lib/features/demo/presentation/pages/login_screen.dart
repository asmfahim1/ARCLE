import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common_widgets/common_app_bar.dart';
import '../../../../core/common_widgets/common_button.dart';
import '../../../../core/common_widgets/common_snackbar.dart';
import '../../../../core/route_handler/app_routes.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/localization/app_strings.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';

/// Login screen for BLoC state management.
/// 
/// This screen is a StatelessWidget that consumes the AuthBloc
/// provided by MultiProvider at the app level.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dimensions = Dimensions(context);
    return Scaffold(
      appBar: CommonAppBar(
        title: context.tr('login_title'),
        showBackButton: false,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.failure) {
            CommonSnackbar.error(
              context,
              message: state.message ?? 'Login failed',
            );
          }
          if (state.status == AuthStatus.success) {
            Navigator.pushReplacementNamed(context, AppRoutes.users);
          }
        },
        child: SingleChildScrollView(
          padding: dimensions.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LoginForm(),
              SizedBox(height: dimensions.height(12)),
              CommonButton(
                label: context.tr('settings'),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
