import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common_widgets/common_button.dart';
import '../../../../core/common_widgets/common_text_field.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/dimensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Login form widget for BLoC state management.
class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final dimensions = Dimensions(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('login_hint'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: dimensions.height(16)),
            CommonTextField(
              labelText: context.tr('email'),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) =>
                  context.read<AuthBloc>().add(EmailChanged(value.trim())),
            ),
            SizedBox(height: dimensions.height(12)),
            CommonTextField(
              labelText: context.tr('password'),
              obscureText: true,
              onChanged: (value) =>
                  context.read<AuthBloc>().add(PasswordChanged(value.trim())),
            ),
            SizedBox(height: dimensions.height(20)),
            CommonButton(
              label: context.tr('login'),
              isLoading: state.status == AuthStatus.loading,
              onPressed: () => context
                  .read<AuthBloc>()
                  .add(LoginSubmitted(state.email, state.password)),
            ),
          ],
        );
      },
    );
  }
}
