import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common_widgets/common_app_bar.dart';
import '../../../../core/common_widgets/common_button.dart';
import '../../../../core/common_widgets/common_loader.dart';
import '../../../../core/route_handler/app_routes.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/localization/app_strings.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/users_bloc.dart';
import '../bloc/users_event.dart';
import '../bloc/users_state.dart';
import '../widgets/user_card.dart';

/// Users list screen for BLoC state management.
/// 
/// This screen is a StatelessWidget that consumes the UsersBloc
/// provided by MultiProvider at the app level.
class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dimensions = Dimensions(context);
    return Scaffold(
      appBar: CommonAppBar(
        title: context.tr('user_list'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<UsersBloc>().add(const RefreshUsers()),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      body: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          switch (state.status) {
            case UsersStatus.loading:
            case UsersStatus.refreshing:
              return const CommonLoader();
            case UsersStatus.failure:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message ?? 'Error'),
                    SizedBox(height: dimensions.height(12)),
                    CommonButton(
                      label: context.tr('retry'),
                      onPressed: () =>
                          context.read<UsersBloc>().add(const LoadUsers()),
                    ),
                  ],
                ),
              );
            case UsersStatus.success:
              return ListView.builder(
                padding: dimensions.all(16),
                itemCount: state.users.length,
                itemBuilder: (_, index) => UserCard(user: state.users[index]),
              );
            case UsersStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
