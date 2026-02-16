import '../../state_management.dart';

class DemoTemplates {
  static Map<String, String> files(StateManagement state) {
    final files = <String, String>{
      // Shared README and domain layer files
      'lib/features/demo/README.md': _readme(),
      'lib/features/demo/domain/entities/user_entity.dart': _userEntity(),
      'lib/features/demo/domain/repositories/demo_repository.dart':
          _demoRepository(),
      'lib/features/demo/domain/usecases/login_usecase.dart':
          _loginUsecase(state),
      'lib/features/demo/domain/usecases/get_users_usecase.dart':
          _getUsersUsecase(state),
      'lib/features/demo/domain/usecases/logout_usecase.dart':
          _logoutUsecase(state),
      // Data layer files
      'lib/features/demo/data/models/login_request.dart': _loginRequest(),
      'lib/features/demo/data/models/user_model.dart': _userModel(),
      'lib/features/demo/data/sources/demo_remote_data_source.dart':
          _remoteDataSource(state),
      'lib/features/demo/data/repositories/demo_repository_impl.dart':
          _demoRepositoryImpl(state),
      // Shared widgets
      'lib/features/demo/presentation/widgets/user_card.dart': _userCard(),
      'lib/features/demo/presentation/widgets/login_form.dart':
          _loginFormWidget(state),
    };

    switch (state) {
      case StateManagement.bloc:
        files.addAll({
          // Pages folder
          'lib/features/demo/presentation/pages/splash_screen.dart':
              _blocSplashScreen(),
          'lib/features/demo/presentation/pages/login_screen.dart':
              _blocLoginScreen(),
          'lib/features/demo/presentation/pages/user_list_screen.dart':
              _blocUsersScreen(),
          // BLoC files
          'lib/features/demo/presentation/bloc/auth_event.dart': _authEvent(),
          'lib/features/demo/presentation/bloc/auth_state.dart':
              _blocAuthState(),
          'lib/features/demo/presentation/bloc/auth_bloc.dart': _authBloc(),
          'lib/features/demo/presentation/bloc/users_event.dart': _usersEvent(),
          'lib/features/demo/presentation/bloc/users_state.dart': _usersState(),
          'lib/features/demo/presentation/bloc/users_bloc.dart': _usersBloc(),
        });
      case StateManagement.getx:
        files.addAll({
          // Pages folder
          'lib/features/demo/presentation/pages/splash_screen.dart':
              _getxSplashScreen(),
          'lib/features/demo/presentation/pages/login_screen.dart':
              _getxLoginScreen(),
          'lib/features/demo/presentation/pages/user_list_screen.dart':
              _getxUsersScreen(),
          // Controller files
          'lib/features/demo/presentation/controller/auth_controller.dart':
              _getxAuthController(),
          'lib/features/demo/presentation/controller/users_controller.dart':
              _getxUsersController(),
          // Bindings
          'lib/features/demo/presentation/bindings/demo_binding.dart':
              _getxBinding(),
        });
      case StateManagement.riverpod:
        files.addAll({
          // Pages folder
          'lib/features/demo/presentation/pages/splash_screen.dart':
              _riverpodSplashScreen(),
          'lib/features/demo/presentation/pages/login_screen.dart':
              _riverpodLoginScreen(),
          'lib/features/demo/presentation/pages/user_list_screen.dart':
              _riverpodUsersScreen(),
          // State and notifier files
          'lib/features/demo/presentation/state/auth_state.dart':
              _riverpodAuthState(),
          'lib/features/demo/presentation/notifiers/auth_notifier.dart':
              _riverpodAuthNotifier(),
          'lib/features/demo/presentation/notifiers/users_notifier.dart':
              _riverpodUsersNotifier(),
          'lib/features/demo/presentation/providers/demo_providers.dart':
              _riverpodProviders(),
        });
    }

    return files;
  }

  static String _readme() => '''
# Demo Feature

This demo shows how to structure a feature using Clean Architecture:

- **data**: Remote data sources and repository implementations
- **domain**: Entities, repository contracts, and use cases
- **presentation**: UI screens, widgets, and state management
  - **pages**: Screen widgets (StatelessWidget)
  - **widgets**: Reusable UI components
  - **bloc/controller/notifiers**: State management classes
''';

  // ==========================================================================
  // Shared Widget Templates
  // ==========================================================================

  static String _userCard() => '''
import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';

/// A reusable card widget for displaying user information.
class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(user.name),
        subtitle: Text(user.email),
      ),
    );
  }
}
''';

  static String _loginFormWidget(StateManagement state) {
    switch (state) {
      case StateManagement.bloc:
        return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common_widgets/common_button.dart';
import '../../../../core/common_widgets/common_text_field.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/route_handler/app_routes.dart';
import '../../../../core/utils/dialogs.dart';
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
                  .add(
                    LoginSubmitted(
                      state.email,
                      state.password,
                      onSuccess: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.users,
                      ),
                      onFailure: AppDialogs.showError,
                    ),
                  ),
            ),
          ],
        );
      },
    );
  }
}
''';
      case StateManagement.getx:
        return '''
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
''';
      case StateManagement.riverpod:
        return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common_widgets/common_button.dart';
import '../../../../core/common_widgets/common_text_field.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/route_handler/app_routes.dart';
import '../../../../core/utils/dialogs.dart';
import '../../../../core/utils/dimensions.dart';
import '../notifiers/auth_notifier.dart';
import '../state/auth_state.dart';

/// Login form widget for Riverpod state management.
class LoginForm extends ConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final notifier = ref.read(authProvider.notifier);
    final dimensions = Dimensions(context);

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
          onChanged: (value) => notifier.updateEmail(value.trim()),
        ),
        SizedBox(height: dimensions.height(12)),
        CommonTextField(
          labelText: context.tr('password'),
          obscureText: true,
          onChanged: (value) => notifier.updatePassword(value.trim()),
        ),
        SizedBox(height: dimensions.height(20)),
        CommonButton(
          label: context.tr('login'),
          isLoading: auth.status == AuthStatus.loading,
          onPressed: () => notifier.login(
            onSuccess: () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.users,
            ),
            onFailure: AppDialogs.showError,
          ),
        ),
      ],
    );
  }
}
''';
    }
  }

  static String _userEntity() => '''
class UserEntity {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
  });

  final int id;
  final String name;
  final String email;
}
''';

  static String _demoRepository() => '''
import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';

abstract class DemoRepository {
  /// Auth
  Future<Result<String>> login(String email, String password);
  Future<Result<void>> logout();

  /// Users
  Future<Result<List<UserEntity>>> getUsers();
}
''';

  static String _loginUsecase(StateManagement state) {
    final injectableImport = state == StateManagement.bloc
        ? "import 'package:injectable/injectable.dart';\n"
        : '';
    final injectableAnno = state == StateManagement.bloc ? '@injectable\n' : '';
    return '''
$injectableImport
import '../../../../core/utils/result.dart';
import '../repositories/demo_repository.dart';

${injectableAnno}class LoginUseCase {
  LoginUseCase(this._repo);

  final DemoRepository _repo;

  Future<Result<String>> call({
    required String email,
    required String password,
  }) {
    return _repo.login(email, password);
  }
}
''';
  }

  static String _getUsersUsecase(StateManagement state) {
    final injectableImport = state == StateManagement.bloc
        ? "import 'package:injectable/injectable.dart';\n"
        : '';
    final injectableAnno = state == StateManagement.bloc ? '@injectable\n' : '';
    return '''
$injectableImport
import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/demo_repository.dart';

${injectableAnno}class GetUsersUseCase {
  GetUsersUseCase(this._repo);

  final DemoRepository _repo;

  Future<Result<List<UserEntity>>> call() {
    return _repo.getUsers();
  }
}
''';
  }

  static String _logoutUsecase(StateManagement state) {
    final injectableImport = state == StateManagement.bloc
        ? "import 'package:injectable/injectable.dart';\n"
        : '';
    final injectableAnno = state == StateManagement.bloc ? '@injectable\n' : '';
    return '''
$injectableImport
import '../../../../core/utils/result.dart';
import '../repositories/demo_repository.dart';

${injectableAnno}class LogoutUseCase {
  LogoutUseCase(this._repo);
  final DemoRepository _repo;

  Future<Result<void>> call() {
    return _repo.logout();
  }
}
''';
  }

  static String _loginRequest() => '''
class LoginRequest {
  LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}
''';

  static String _userModel() => '''
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      email: _asString(json['email']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _asString(dynamic value) {
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    return '';
  }
}
''';

  static String _remoteDataSource(StateManagement state) {
    final injectableImport = state == StateManagement.bloc
        ? "import 'package:injectable/injectable.dart';\n"
        : '';
    final injectableAnno = state == StateManagement.bloc ? '@injectable\n' : '';
    return '''
import 'dart:async';
import 'package:dio/dio.dart';
$injectableImport
import '../../../../core/api_client/api_service.dart';
import '../models/login_request.dart';

$injectableAnno
class DemoRemoteDataSource {
  DemoRemoteDataSource(this._apiService);

  final ApiService _apiService;

  /// Demo login. Replace with your real API later.\r\n  Future<Response<dynamic>> login(LoginRequest request) async {\r\n    return _apiService.post('/auth/login', data: request.toJson());\r\n  }

  /// Fetch users from JSONPlaceholder (uses token from SessionManager in Dio).
  Future<Response<dynamic>> fetchUsers() async {
    return _apiService.get('/users');
  }
}
''';
  }

  static String _demoRepositoryImpl(StateManagement state) {
    final injectableImport = state == StateManagement.bloc
        ? "import 'package:injectable/injectable.dart';\n"
        : '';
    final injectableAnno = state == StateManagement.bloc
        ? '@LazySingleton(as: DemoRepository)\n'
        : '';
    return '''
$injectableImport
import 'package:dartz/dartz.dart';
import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/session_manager/session_manager.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/demo_repository.dart';
import '../models/login_request.dart';
import '../models/user_model.dart';
import '../sources/demo_remote_data_source.dart';

$injectableAnno
class DemoRepositoryImpl implements DemoRepository {
  DemoRepositoryImpl(this._remote, this._sessionManager);

  final DemoRemoteDataSource _remote;
  final SessionManager _sessionManager;

  @override
  Future<Result<String>> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return Left(ValidationFailure('Please enter email and password'));
    }
    try {
      final response = await _remote.login(
        LoginRequest(email: email, password: password),
      );
      final token = response.data['token']?.toString() ?? '';
      await _sessionManager.saveSession(accessToken: token);
      return Right(token);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<List<UserEntity>>> getUsers() async {
    try {
      final response = await _remote.fetchUsers();
      final data = response.data as List<dynamic>;
      final users = data
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Right(users);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _sessionManager.clearToken();
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
''';
  }

  static String _authEvent() => '''
  import 'package:equatable/equatable.dart';
  import 'package:flutter/foundation.dart';
  
  abstract class AuthEvent extends Equatable {
    const AuthEvent();
  
    @override
    List<Object?> get props => [];
  }
  
  class EmailChanged extends AuthEvent {
    const EmailChanged(this.email);
  
    final String email;
  
    @override
    List<Object?> get props => [email];
  }
  
  class PasswordChanged extends AuthEvent {
    const PasswordChanged(this.password);
  
    final String password;
  
    @override
    List<Object?> get props => [password];
  }
  
  class LoginSubmitted extends AuthEvent {
    const LoginSubmitted(
      this.email,
      this.password, {
      this.onSuccess,
      this.onFailure,
    });
  
    final String email;
    final String password;
    final VoidCallback? onSuccess;
    final ValueChanged<String>? onFailure;

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
''';

  static String _blocAuthState() => '''
import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  const AuthState({
    this.email = '',
    this.password = '',
    this.status = AuthStatus.initial,
    this.message,
  });

  final String email;
  final String password;
  final AuthStatus status;
  final String? message;

  AuthState copyWith({
    String? email,
    String? password,
    AuthStatus? status,
    String? message,
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [email, password, status, message];
}
''';

  static String _authBloc() => '''
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._loginUseCase, this._logoutUseCase)
      : super(const AuthState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

    void _onEmailChanged(
      EmailChanged event,
      Emitter<AuthState> emit,
    ) {
      emit(state.copyWith(email: event.email));
    }
  
    void _onPasswordChanged(
      PasswordChanged event,
      Emitter<AuthState> emit,
    ) {
      emit(state.copyWith(password: event.password));
    }
  
    Future<void> _onLogin(
      LoginSubmitted event,
      Emitter<AuthState> emit,
    ) async {
    emit(state.copyWith(status: AuthStatus.loading, message: null));
    final result = await _loginUseCase(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: AuthStatus.failure,
          message: failure.message,
        ));
        event.onFailure?.call(failure.message);
      },
      (_) {
        emit(state.copyWith(status: AuthStatus.success));
        event.onSuccess?.call();
      },
    );
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logoutUseCase();
    emit(state.copyWith(status: AuthStatus.initial));
  }
}
''';

  static String _usersEvent() => '''
import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends UsersEvent {
  const LoadUsers();
}

class RefreshUsers extends UsersEvent {
  const RefreshUsers();
}
''';

  static String _usersState() => '''
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

enum UsersStatus { initial, loading, refreshing, success, failure }

class UsersState extends Equatable {
  const UsersState({
    this.status = UsersStatus.initial,
    this.users = const [],
    this.message,
  });

  final UsersStatus status;
  final List<UserEntity> users;
  final String? message;

  UsersState copyWith({
    UsersStatus? status,
    List<UserEntity>? users,
    String? message,
  }) {
    return UsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, users, message];
}
''';

  static String _usersBloc() => '''
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_users_usecase.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc(this._getUsersUseCase) : super(const UsersState()) {
    on<LoadUsers>(_onLoad);
    on<RefreshUsers>(_onRefresh);
  }

  final GetUsersUseCase _getUsersUseCase;

  Future<void> _onLoad(LoadUsers event, Emitter<UsersState> emit) async {
    emit(state.copyWith(status: UsersStatus.loading, message: null));
    final result = await _getUsersUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        status: UsersStatus.failure,
        message: failure.message,
      )),
      (users) => emit(state.copyWith(
        status: UsersStatus.success,
        users: users,
      )),
    );
  }

  Future<void> _onRefresh(
    RefreshUsers event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(status: UsersStatus.refreshing, message: null));
    final result = await _getUsersUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        status: UsersStatus.failure,
        message: failure.message,
      )),
      (users) => emit(state.copyWith(
        status: UsersStatus.success,
        users: users,
      )),
    );
  }
}
''';

  static String _blocLoginScreen() => '''
import 'package:flutter/material.dart';

import '../../../../core/common_widgets/common_app_bar.dart';
import '../../../../core/common_widgets/common_button.dart';
import '../../../../core/route_handler/app_routes.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/localization/app_strings.dart';
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
      body: SingleChildScrollView(
        padding: dimensions.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LoginForm(),
            SizedBox(height: dimensions.height(12)),
            CommonButton(
              label: context.tr('settings'),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
          ],
        ),
      ),
    );
  }
}
''';

  static String _blocUsersScreen() => '''
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
''';

  static String _getxAuthController() => '''
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

enum AuthStatus { initial, loading, success, failure }

  class AuthController extends GetxController {
    AuthController(this._loginUseCase, this._logoutUseCase);
  
    final LoginUseCase _loginUseCase;
    final LogoutUseCase _logoutUseCase;
  
    final email = ''.obs;
    final password = ''.obs;
    final status = AuthStatus.initial.obs;
    final error = RxnString();
  
    void setEmail(String value) => email.value = value;
  
    void setPassword(String value) => password.value = value;
  
    Future<void> login(
      String email,
      String password, {
      VoidCallback? onSuccess,
      ValueChanged<String>? onFailure,
    }) async {
      if (status.value == AuthStatus.loading) return;
      status.value = AuthStatus.loading;
      error.value = null;
    final result = await _loginUseCase(
      email: email,
      password: password,
    );
    result.fold(
      (failure) {
        status.value = AuthStatus.failure;
        error.value = failure.message;
        onFailure?.call(failure.message);
      },
      (_) {
        status.value = AuthStatus.success;
        onSuccess?.call();
      },
    );
  }

  Future<void> logout() async {
    await _logoutUseCase();
    status.value = AuthStatus.initial;
  }

  void reset() {
    status.value = AuthStatus.initial;
    error.value = null;
  }
}
''';

  static String _getxUsersController() => '''
import 'package:get/get.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_users_usecase.dart';

class UsersController extends GetxController {
  UsersController(this._getUsersUseCase);

  final GetUsersUseCase _getUsersUseCase;

  final users = <UserEntity>[].obs;
  final loading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    final result = await _getUsersUseCase();
    result.fold(
      (failure) => error.value = failure.message,
      (list) => users.assignAll(list),
    );
    loading.value = false;
  }
}
''';

  static String _getxBinding() => '''
import 'package:get/get.dart';

import '../../../../core/api_client/api_service.dart';
import '../../../../core/session_manager/session_manager.dart';
import '../../data/repositories/demo_repository_impl.dart';
import '../../data/sources/demo_remote_data_source.dart';
import '../../domain/repositories/demo_repository.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../controller/auth_controller.dart';
import '../controller/users_controller.dart';

class DemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DemoRemoteDataSource(Get.find<ApiService>()));
    Get.lazyPut<DemoRepository>(
      () => DemoRepositoryImpl(
        Get.find<DemoRemoteDataSource>(),
        Get.find<SessionManager>(),
      ),
    );
    Get.lazyPut(() => LoginUseCase(Get.find<DemoRepository>()));
    Get.lazyPut(() => LogoutUseCase(Get.find<DemoRepository>()));
    Get.lazyPut(() => GetUsersUseCase(Get.find<DemoRepository>()));
    Get.lazyPut(
      () => AuthController(
        Get.find<LoginUseCase>(),
        Get.find<LogoutUseCase>(),
      ),
    );
    Get.lazyPut(() => UsersController(Get.find<GetUsersUseCase>()));
  }
}
''';

  static String _getxLoginScreen() => '''
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
''';

  static String _getxUsersScreen() => '''
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
''';

  static String _riverpodProviders() => '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../domain/repositories/demo_repository.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../data/repositories/demo_repository_impl.dart';
import '../../data/sources/demo_remote_data_source.dart';

/// Remote data source provider for demo feature.
final demoRemoteDataSourceProvider = Provider<DemoRemoteDataSource>((ref) {
  return DemoRemoteDataSource(ref.watch(apiServiceProvider));
});

/// Repository provider for demo feature.
final demoRepositoryProvider = Provider<DemoRepository>((ref) {
  return DemoRepositoryImpl(
    ref.watch(demoRemoteDataSourceProvider),
    ref.watch(sessionManagerProvider),
  );
});

/// Login use case provider.
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(demoRepositoryProvider));
});

/// Logout use case provider.
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(demoRepositoryProvider));
});

/// Get users use case provider.
final getUsersUseCaseProvider = Provider<GetUsersUseCase>((ref) {
  return GetUsersUseCase(ref.watch(demoRepositoryProvider));
});
''';

  static String _riverpodAuthState() => '''
import 'package:flutter/foundation.dart';

enum AuthStatus { initial, loading, success, failure }

/// Immutable auth state for Riverpod state management.
@immutable
class AuthState {
  const AuthState({
    this.email = '',
    this.password = '',
    this.status = AuthStatus.initial,
    this.message,
  });

  final String email;
  final String password;
  final AuthStatus status;
  final String? message;

  bool get isLoading => status == AuthStatus.loading;
  bool get isSuccess => status == AuthStatus.success;
  bool get isFailure => status == AuthStatus.failure;

  AuthState copyWith({
    String? email,
    String? password,
    AuthStatus? status,
    String? message,
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.email == email &&
        other.password == password &&
        other.status == status &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(email, password, status, message);
}
''';

  static String _riverpodAuthNotifier() => '''
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../state/auth_state.dart';
import '../providers/demo_providers.dart';

/// Auth state notifier for handling authentication logic.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._loginUseCase, this._logoutUseCase)
      : super(const AuthState());

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  void updateEmail(String value) {
    state = state.copyWith(email: value);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value);
  }

  /// Attempt to login with email and password.
  Future<void> login({
    VoidCallback? onSuccess,
    ValueChanged<String>? onFailure,
  }) async {
    if (state.status == AuthStatus.loading) return;
    state = state.copyWith(status: AuthStatus.loading, message: null);
    final result = await _loginUseCase(
      email: state.email,
      password: state.password,
    );
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.failure,
          message: failure.message,
        );
        onFailure?.call(failure.message);
      },
      (_) {
        state = state.copyWith(status: AuthStatus.success);
        onSuccess?.call();
      },
    );
  }

  /// Logout and reset state.
  Future<void> logout() async {
    await _logoutUseCase();
    state = state.copyWith(status: AuthStatus.initial);
  }

  /// Reset state to initial (useful after handling errors).
  void reset() {
    state = const AuthState();
  }
}

/// Auth provider using StateNotifierProvider.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(loginUseCaseProvider),
    ref.watch(logoutUseCaseProvider),
  );
});
''';

  static String _riverpodUsersNotifier() => '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../providers/demo_providers.dart';

/// State class for users list.
class UsersState {
  const UsersState({
    this.loading = false,
    this.users = const [],
    this.message,
  });

  final bool loading;
  final List<UserEntity> users;
  final String? message;

  bool get hasError => message != null;
  bool get isEmpty => users.isEmpty && !loading && !hasError;

  UsersState copyWith({
    bool? loading,
    List<UserEntity>? users,
    String? message,
  }) {
    return UsersState(
      loading: loading ?? this.loading,
      users: users ?? this.users,
      message: message ?? this.message,
    );
  }
}

/// Users state notifier for managing user list.
class UsersNotifier extends StateNotifier<UsersState> {
  UsersNotifier(this._getUsersUseCase) : super(const UsersState());

  final GetUsersUseCase _getUsersUseCase;

  /// Load users from the API.
  Future<void> load() async {
    state = state.copyWith(loading: true, message: null);
    final result = await _getUsersUseCase();
    result.fold(
      (failure) => state = state.copyWith(
        loading: false,
        message: failure.message,
      ),
      (users) => state = state.copyWith(
        loading: false,
        users: users,
      ),
    );
  }

  /// Refresh users (alias for load with visual feedback).
  Future<void> refresh() async => load();

  /// Clear the users list.
  void clear() {
    state = const UsersState();
  }
}

/// Users provider using StateNotifierProvider.
final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  return UsersNotifier(ref.watch(getUsersUseCaseProvider));
});
''';

  static String _riverpodLoginScreen() => '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common_widgets/common_app_bar.dart';
import '../../../../core/common_widgets/common_button.dart';
import '../../../../core/route_handler/app_routes.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/localization/app_strings.dart';
import '../notifiers/auth_notifier.dart';
import '../widgets/login_form.dart';

/// Login screen for Riverpod state management.
/// 
/// Uses ConsumerWidget to automatically rebuild when state changes.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dimensions = Dimensions(context);

    return Scaffold(
      appBar: CommonAppBar(
        title: context.tr('login_title'),
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: dimensions.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LoginForm(),
            SizedBox(height: dimensions.height(12)),
            CommonButton(
              label: context.tr('settings'),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
          ],
        ),
      ),
    );
  }
}
''';

  static String _riverpodUsersScreen() => '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common_widgets/common_app_bar.dart';
import '../../../../core/common_widgets/common_button.dart';
import '../../../../core/common_widgets/common_loader.dart';
import '../../../../core/route_handler/app_routes.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../notifiers/auth_notifier.dart';
import '../notifiers/users_notifier.dart';
import '../widgets/user_card.dart';

/// Users list screen for Riverpod state management.
/// 
/// Uses ConsumerWidget to automatically rebuild when state changes.
class UsersListScreen extends ConsumerStatefulWidget {
  const UsersListScreen({super.key});

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  @override
  void initState() {
    super.initState();
    // Load users when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersProvider);
    final usersNotifier = ref.read(usersProvider.notifier);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: CommonAppBar(
        title: context.tr('user_list'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: usersNotifier.load,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authNotifier.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: _buildBody(context, usersState, usersNotifier),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSessionInfo(context),
        child: const Icon(Icons.info_outline),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    UsersState usersState,
    UsersNotifier usersNotifier,
  ) {
    if (usersState.loading && usersState.users.isEmpty) {
      return const CommonLoader();
    }

    if (usersState.hasError && usersState.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(usersState.message ?? 'Error'),
            const SizedBox(height: 12),
            CommonButton(
              label: context.tr('retry'),
              onPressed: usersNotifier.load,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: usersNotifier.refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: usersState.users.length,
        itemBuilder: (_, index) => UserCard(user: usersState.users[index]),
      ),
    );
  }

  void _showSessionInfo(BuildContext context) async {
    final session = ref.read(sessionManagerProvider);
    final token = await session.getToken() ?? 'No token';
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.tr('session_info')),
        content: SelectableText('Token: \$token'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('close')),
          ),
        ],
      ),
    );
  }
}
''';

  static String _blocSplashScreen() => '''
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
''';

  static String _getxSplashScreen() => '''
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
''';

  static String _riverpodSplashScreen() => '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/route_handler/app_routes.dart';

/// Splash screen for Riverpod state management.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  Future<void> _route(BuildContext context, WidgetRef ref) async {
    final session = ref.read(sessionManagerProvider);
    final isLoggedIn = await session.isAuthenticated;
    final target = isLoggedIn ? AppRoutes.users : AppRoutes.login;
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, target);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _route(context, ref));
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
                    Icons.waving_hand_rounded,
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
                  'Finalizing setup...',
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
''';
}
