import '../../state_management.dart';

class DemoTemplates {
  static Map<String, String> files(StateManagement state) {
    final files = <String, String>{
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
      'lib/features/demo/data/models/login_request.dart': _loginRequest(),
      'lib/features/demo/data/models/user_model.dart': _userModel(),
      'lib/features/demo/data/sources/demo_remote_data_source.dart':
          _remoteDataSource(state),
      'lib/features/demo/data/repositories/demo_repository_impl.dart':
          _demoRepositoryImpl(state),
    };

    switch (state) {
      case StateManagement.bloc:
        files.addAll({
          'lib/features/demo/presentation/bloc/auth_event.dart': _authEvent(),
          'lib/features/demo/presentation/bloc/auth_state.dart': _authState(),
          'lib/features/demo/presentation/bloc/auth_bloc.dart': _authBloc(),
          'lib/features/demo/presentation/bloc/users_event.dart': _usersEvent(),
          'lib/features/demo/presentation/bloc/users_state.dart': _usersState(),
          'lib/features/demo/presentation/bloc/users_bloc.dart': _usersBloc(),
          'lib/features/demo/presentation/login_screen.dart':
              _blocLoginScreen(),
          'lib/features/demo/presentation/user_list_screen.dart':
              _blocUsersScreen(),
        });
      case StateManagement.getx:
        files.addAll({
          'lib/features/demo/presentation/controller/auth_controller.dart':
              _getxAuthController(),
          'lib/features/demo/presentation/controller/users_controller.dart':
              _getxUsersController(),
          'lib/features/demo/presentation/login_screen.dart':
              _getxLoginScreen(),
          'lib/features/demo/presentation/user_list_screen.dart':
              _getxUsersScreen(),
        });
      case StateManagement.riverpod:
        files.addAll({
          'lib/features/demo/presentation/auth_state.dart': _authState(),
          'lib/features/demo/presentation/auth_notifier.dart':
              _riverpodAuthNotifier(),
          'lib/features/demo/presentation/users_notifier.dart':
              _riverpodUsersNotifier(),
          'lib/features/demo/presentation/demo_providers.dart':
              _riverpodProviders(),
          'lib/features/demo/presentation/login_screen.dart':
              _riverpodLoginScreen(),
          'lib/features/demo/presentation/user_list_screen.dart':
              _riverpodUsersScreen(),
        });
    }

    return files;
  }

  static String _readme() => '''
# Demo Feature

This demo shows how to structure a feature using Clean Architecture:

- data: remote data sources and repository implementations
- domain: entities + repository contracts + use cases
- presentation: UI + state management
''';

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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
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

  /// Demo login. Replace with your real API later.
  Future<Response<dynamic>> login(LoginRequest request) async {
    // Example of how to call an API:
    // return _apiService.post('/auth/login', data: request.toJson());
    await Future.delayed(const Duration(milliseconds: 800));
    return Response(
      data: {'token': 'demo_token_\${DateTime.now().millisecondsSinceEpoch}'},
      statusCode: 200,
      requestOptions: RequestOptions(path: '/auth/login'),
    );
  }

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
import '../../../../core/session_manager/session_manager.dart';
import '../../../../core/utils/app_failure.dart';
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
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
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
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    await _sessionManager.clearToken();
    return const Right(null);
  }
}
''';
  }

  static String _authEvent() => '''
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted(this.email, this.password);

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
''';

  static String _authState() => '''
import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.message,
  });

  final AuthStatus status;
  final String? message;

  AuthState copyWith({
    AuthStatus? status,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
''';

  static String _authBloc() => '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._loginUseCase, this._logoutUseCase)
      : super(const AuthState()) {
    on<LoginSubmitted>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

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
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        message: failure.message,
      )),
      (_) => emit(state.copyWith(status: AuthStatus.success)),
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
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_users_usecase.dart';
import 'users_event.dart';
import 'users_state.dart';

@injectable
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
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/common_widgets/common_app_bar.dart';
import '../../../core/common_widgets/common_button.dart';
import '../../../core/common_widgets/common_checkbox.dart';
import '../../../core/common_widgets/common_dropdown.dart';
import '../../../core/common_widgets/common_snackbar.dart';
import '../../../core/common_widgets/common_text_field.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/route_handler/app_routes.dart';
import '../../../core/utils/dimensions.dart';
import '../../settings/presentation/app_settings_cubit.dart';
import '../../settings/presentation/app_settings_state.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'demo@arcle.dev');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    context.read<AuthBloc>().add(
          LoginSubmitted(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = Dimensions(context);
    return Scaffold(
      appBar: CommonAppBar(
        title: context.tr('login_title'),
        showBackButton: false,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
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
        builder: (context, state) {
          return SingleChildScrollView(
            padding: dimensions.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.tr('login_hint'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: dimensions.height(16)),
                CommonTextField(
                  controller: _emailController,
                  labelText: context.tr('email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: dimensions.height(12)),
                CommonTextField(
                  controller: _passwordController,
                  labelText: context.tr('password'),
                  obscureText: true,
                ),
                SizedBox(height: dimensions.height(20)),
                CommonButton(
                  label: context.tr('login'),
                  isLoading: state.status == AuthStatus.loading,
                  onPressed: () => _submit(context),
                ),
                SizedBox(height: dimensions.height(12)),
                CommonButton(
                  label: context.tr('settings'),
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.settings),
                ),
                SizedBox(height: dimensions.height(20)),
                BlocBuilder<AppSettingsCubit, AppSettingsState>(
                  builder: (context, settings) {
                    return Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: dimensions.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('theme'),
                              style:
                                  Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: dimensions.height(8)),
                            CommonCheckbox(
                              value:
                                  settings.themeMode == ThemeMode.dark,
                              label: context.tr('dark_mode'),
                              onChanged: (value) => context
                                  .read<AppSettingsCubit>()
                                  .toggleTheme(value ?? false),
                            ),
                            SizedBox(height: dimensions.height(12)),
                            Text(
                              context.tr('language'),
                              style:
                                  Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: dimensions.height(8)),
                            CommonDropdown<Locale>(
                              value: settings.locale,
                              items: AppStrings.supportedLocales,
                              itemLabel: (loc) =>
                                  loc.languageCode.toUpperCase(),
                              onChanged: (value) {
                                if (value != null) {
                                  context
                                      .read<AppSettingsCubit>()
                                      .changeLocale(value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
''';

  static String _blocUsersScreen() => '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/core/localization/app_strings.dart';

import '../../../core/common_widgets/common_app_bar.dart';
import '../../../core/common_widgets/common_button.dart';
import '../../../core/common_widgets/common_loader.dart';
import '../../../core/route_handler/app_routes.dart';
import '../../../core/session_manager/session_manager.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/di/injection.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/users_bloc.dart';
import 'bloc/users_event.dart';
import 'bloc/users_state.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UsersBloc>()..add(const LoadUsers()),
      child: const UsersListView(),
    );
  }
}

class UsersListView extends StatelessWidget {
  const UsersListView({super.key});

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
                      onPressed: () => context
                          .read<UsersBloc>()
                          .add(const LoadUsers()),
                    ),
                  ],
                ),
              );
            case UsersStatus.success:
              return ListView.separated(
                padding: dimensions.all(16),
                itemCount: state.users.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: dimensions.height(8)),
                itemBuilder: (_, index) {
                  final user = state.users[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    leading: CircleAvatar(child: Text(user.name[0])),
                  );
                },
              );
            case UsersStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final token = getIt<SessionManager>().getToken();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Session Info'),
              content: Text('Token: \$token'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.info_outline),
      ),
    );
  }
}
''';

  static String _getxAuthController() => '''
import 'package:get/get.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthController extends GetxController {
  AuthController(this._loginUsecase, this._logoutUsecase);

  final LoginUsecase _loginUsecase;
  final LogoutUsecase _logoutUsecase;

  final status = AuthStatus.initial.obs;
  final error = RxnString();

  Future<void> login(String email, String password) async {
    if (status.value == AuthStatus.loading) return;
    status.value = AuthStatus.loading;
    error.value = null;
    final result = await _loginUsecase(
      email: email,
      password: password,
    );
    result.fold(
      (failure) {
        status.value = AuthStatus.failure;
        error.value = failure.message;
      },
      (_) => status.value = AuthStatus.success,
    );
  }

  Future<void> logout() async {
    await _logoutUsecase();
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
  UsersController(this._getUsersUsecase);

  final GetUsersUsecase _getUsersUsecase;

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
    final result = await _getUsersUsecase();
    result.fold(
      (failure) => error.value = failure.message,
      (list) => users.assignAll(list),
    );
    loading.value = false;
  }
}
''';

  static String _getxLoginScreen() => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common_widgets/common_app_bar.dart';
import '../../../core/common_widgets/common_button.dart';
import '../../../core/common_widgets/common_checkbox.dart';
import '../../../core/common_widgets/common_dropdown.dart';
import '../../../core/common_widgets/common_snackbar.dart';
import '../../../core/common_widgets/common_text_field.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/route_handler/getx_routes.dart';
import '../../../core/utils/dimensions.dart';
import '../../settings/presentation/app_settings_controller.dart';
import 'controller/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'demo@arcle.dev');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(AuthController controller) {
    controller.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Scaffold(
      // Localization: context.tr(...) pulls from GetX translations.
      appBar: CommonAppBar(
        title: context.tr('login_title'),
        showBackButton: false,
      ),
      body: Obx(() {
        if (controller.status.value == AuthStatus.failure &&
            controller.error.value != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            CommonSnackbar.error(
              context,
              message: controller.error.value ?? 'Login failed',
            );
            controller.reset();
          });
        }

        if (controller.status.value == AuthStatus.success) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.reset();
            Get.offNamed(GetxRoutes.users);
          });
        }

        return SingleChildScrollView(
          // Dimensions keeps spacing consistent across devices.
          padding: Dimensions.allPadding(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr('login_hint'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: Dimensions.height(16)),
              CommonTextField(
                controller: _emailController,
                labelText: context.tr('email'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: Dimensions.height(12)),
              CommonTextField(
                controller: _passwordController,
                labelText: context.tr('password'),
                obscureText: true,
              ),
              SizedBox(height: Dimensions.height(20)),
              CommonButton(
                label: context.tr('login'),
                isLoading: controller.status.value == AuthStatus.loading,
                onPressed: () => _submit(controller),
              ),
              SizedBox(height: Dimensions.height(12)),
              CommonButton(
                label: context.tr('settings'),
                onPressed: () => Get.toNamed(GetxRoutes.settings),
              ),
              SizedBox(height: Dimensions.height(20)),
              _SettingsPanel(),
            ],
          ),
        );
      }),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsController>();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: Dimensions.allPadding(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('theme'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: Dimensions.height(8)),
            Obx(() {
              return CommonCheckbox(
                value: settings.themeMode.value == ThemeMode.dark,
                label: context.tr('dark_mode'),
                onChanged: (value) =>
                    settings.toggleTheme(value ?? false),
              );
            }),
            SizedBox(height: Dimensions.height(12)),
            Text(
              context.tr('language'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: Dimensions.height(8)),
            Obx(() {
              return CommonDropdown<Locale>(
                value: settings.locale.value,
                items: AppStrings.supportedLocales,
                itemLabel: (loc) => loc.languageCode.toUpperCase(),
                onChanged: (value) {
                  if (value != null) {
                    settings.changeLocale(value);
                  }
                },
              );
            }),
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
import 'package:test_app/core/localization/app_strings.dart';

import '../../../core/common_widgets/common_app_bar.dart';
import '../../../core/common_widgets/common_button.dart';
import '../../../core/common_widgets/common_loader.dart';
import '../../../core/common_widgets/common_checkbox.dart';
import '../../../core/common_widgets/common_dropdown.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/route_handler/getx_routes.dart';
import '../../../core/session_manager/session_manager.dart';
import '../../settings/presentation/app_settings_controller.dart';
import 'controller/auth_controller.dart';
import 'controller/users_controller.dart';

class UsersListScreen extends StatelessWidget {
  UsersListScreen({super.key});

  final UsersController usersController = Get.find<UsersController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Localization: context.tr(...) reads translated strings.
      appBar: CommonAppBar(
        title: context.tr('user_list'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: usersController.load,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authController.logout();
              Get.offAllNamed(GetxRoutes.login);
            },
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
                Text(usersController.error.value ?? 'Error'),
                const SizedBox(height: 12),
                CommonButton(
                  label: context.tr('retry'),
                  onPressed: usersController.load,
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          // Dimensions keeps spacing consistent across devices.
          padding: const EdgeInsets.all(16),
          itemCount: usersController.users.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, index) {
            if (index == 0) {
              final settings = Get.find<AppSettingsController>();
              return Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('theme'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        return CommonCheckbox(
                          value: settings.themeMode.value == ThemeMode.dark,
                          label: context.tr('dark_mode'),
                          onChanged: (value) =>
                              settings.toggleTheme(value ?? false),
                        );
                      }),
                      const SizedBox(height: 12),
                      Text(
                        context.tr('language'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        return CommonDropdown<Locale>(
                          value: settings.locale.value,
                          items: AppStrings.supportedLocales,
                          itemLabel: (loc) =>
                              loc.languageCode.toUpperCase(),
                          onChanged: (value) {
                            if (value != null) {
                              settings.changeLocale(value);
                            }
                          },
                        );
                      }),
                    ],
                  ),
                ),
              );
            }
            final user = usersController.users[index - 1];
            return ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
              leading: CircleAvatar(child: Text(user.name[0])),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final session = Get.find<SessionManager>();
          // Token is stored after login via SessionManager.
          final token = await session.getToken() ?? 'No token';
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Session Info'),
              content: Text('Token: \$token'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.info_outline),
      ),
    );
  }
}
''';

  static String _riverpodProviders() => '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../domain/repositories/demo_repository.dart';
import '../domain/usecases/get_users_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../data/repositories/demo_repository_impl.dart';
import '../data/sources/demo_remote_data_source.dart';

final demoRepositoryProvider = Provider<DemoRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  final session = ref.watch(sessionManagerProvider);
  final remote = DemoRemoteDataSource(api);
  return DemoRepositoryImpl(remote, session);
});

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(ref.watch(demoRepositoryProvider));
});

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  return LogoutUsecase(ref.watch(demoRepositoryProvider));
});

final getUsersUsecaseProvider = Provider<GetUsersUsecase>((ref) {
  return GetUsersUsecase(ref.watch(demoRepositoryProvider));
});
''';

  static String _riverpodAuthNotifier() => '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';
import 'demo_providers.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._loginUsecase, this._logoutUsecase)
      : super(const AuthState());

  final LoginUsecase _loginUsecase;
  final LogoutUsecase _logoutUsecase;

  Future<void> login(String email, String password) async {
    if (state.status == AuthStatus.loading) return;
    state = state.copyWith(status: AuthStatus.loading, message: null);
    final result = await _loginUsecase(
      email: email,
      password: password,
    );
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.failure,
        message: failure.message,
      ),
      (_) => state = state.copyWith(status: AuthStatus.success),
    );
  }

  Future<void> logout() async {
    await _logoutUsecase();
    state = state.copyWith(status: AuthStatus.initial);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(loginUsecaseProvider),
    ref.watch(logoutUsecaseProvider),
  );
});
''';

  static String _riverpodUsersNotifier() => '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/user_entity.dart';
import '../domain/usecases/get_users_usecase.dart';
import 'demo_providers.dart';

class UsersState {
  const UsersState({
    this.loading = false,
    this.users = const [],
    this.message,
  });

  final bool loading;
  final List<UserEntity> users;
  final String? message;

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

class UsersNotifier extends StateNotifier<UsersState> {
  UsersNotifier(this._getUsersUsecase) : super(const UsersState());

  final GetUsersUsecase _getUsersUsecase;

  Future<void> load() async {
    state = state.copyWith(loading: true, message: null);
    final result = await _getUsersUsecase();
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
}

final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  return UsersNotifier(ref.watch(getUsersUsecaseProvider));
});
''';

  static String _riverpodLoginScreen() => '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common_widgets/common_app_bar.dart';
import '../../../core/common_widgets/common_button.dart';
import '../../../core/common_widgets/common_checkbox.dart';
import '../../../core/common_widgets/common_dropdown.dart';
import '../../../core/common_widgets/common_snackbar.dart';
import '../../../core/common_widgets/common_text_field.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/route_handler/app_routes.dart';
import '../../../core/utils/dimensions.dart';
import '../../settings/presentation/app_settings_provider.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'demo@arcle.dev');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  void initState() {
    super.initState();
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.failure && next.message != null) {
        CommonSnackbar.error(
          context,
          message: next.message ?? 'Login failed',
        );
      }
      if (next.status == AuthStatus.success) {
        Navigator.pushReplacementNamed(context, AppRoutes.users);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(AuthNotifier notifier) {
    notifier.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final notifier = ref.read(authProvider.notifier);
    final settings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);
    // Dimensions keeps spacing consistent across devices.
    final dimensions = Dimensions(context);
    return Scaffold(
      // Localization: context.tr(...) reads from AppLocalizations.
      appBar: CommonAppBar(
        title: context.tr('login_title'),
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: dimensions.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('login_hint'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: dimensions.height(16)),
            CommonTextField(
              controller: _emailController,
              labelText: context.tr('email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: dimensions.height(12)),
            CommonTextField(
              controller: _passwordController,
              labelText: context.tr('password'),
              obscureText: true,
            ),
            SizedBox(height: dimensions.height(20)),
            CommonButton(
              label: context.tr('login'),
              isLoading: auth.status == AuthStatus.loading,
              onPressed: () => _submit(notifier),
            ),
            SizedBox(height: dimensions.height(12)),
            CommonButton(
              label: context.tr('settings'),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.settings),
            ),
            SizedBox(height: dimensions.height(20)),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: dimensions.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('theme'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: dimensions.height(8)),
                    CommonCheckbox(
                      value: settings.themeMode == ThemeMode.dark,
                      label: context.tr('dark_mode'),
                      onChanged: (value) =>
                          settingsNotifier.toggleTheme(value ?? false),
                    ),
                    SizedBox(height: dimensions.height(12)),
                    Text(
                      context.tr('language'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: dimensions.height(8)),
                    CommonDropdown<Locale>(
                      value: settings.locale,
                      items: AppStrings.supportedLocales,
                      itemLabel: (loc) =>
                          loc.languageCode.toUpperCase(),
                      onChanged: (value) {
                        if (value != null) {
                          settingsNotifier.changeLocale(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
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
import 'package:test_app/core/localization/app_strings.dart';

import '../../../core/common_widgets/common_app_bar.dart';
import '../../../core/common_widgets/common_button.dart';
import '../../../core/common_widgets/common_loader.dart';
import '../../../core/route_handler/app_routes.dart';
import '../../../core/session_manager/session_manager.dart';
import '../../../core/di/providers.dart';
import 'auth_notifier.dart';
import 'users_notifier.dart';

class UsersListScreen extends ConsumerWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(usersProvider);
    final usersNotifier = ref.read(usersProvider.notifier);
    final authNotifier = ref.read(authProvider.notifier);
    return Scaffold(
      // Localization: context.tr(...) reads from AppLocalizations.
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
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      body: usersState.loading
          ? const CommonLoader()
          : usersState.message != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(usersState.message ?? 'Error'),
                      const SizedBox(height: 12),
                      CommonButton(
                        label: context.tr('retry'),
                        onPressed: usersNotifier.load,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: usersState.users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final user = usersState.users[index];
                    return ListTile(
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      leading: CircleAvatar(child: Text(user.name[0])),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final session = ref.read(sessionManagerProvider);
          // Token is stored after login via SessionManager.
          final token = await session.getToken() ?? 'No token';
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Session Info'),
              content: Text('Token: \$token'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.info_outline),
      ),
    );
  }
}
''';
}
