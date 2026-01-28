import '../state_management.dart';

class TestsTemplates {
  static String widgetTest(StateManagement state) {
    switch (state) {
      case StateManagement.getx:
        return '''
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../lib/app/app.dart';
import '../lib/features/settings/presentation/app_settings_controller.dart';

void main() {
  testWidgets('App builds', (tester) async {
    Get.put(AppSettingsController(), permanent: true);
    await tester.pumpWidget(const App());
    expect(find.byType(App), findsOneWidget);
  });
}
''';
      case StateManagement.riverpod:
        return '''
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../lib/app/app.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    expect(find.byType(App), findsOneWidget);
  });
}
''';
      default:
        return '''
import 'package:flutter_test/flutter_test.dart';

import '../lib/app/app.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(App), findsOneWidget);
  });
}
''';
    }
  }

  static String loginScreenTest(StateManagement state) {
    switch (state) {
      case StateManagement.bloc:
        return _blocLoginScreenTest();
      case StateManagement.getx:
        return _getxLoginScreenTest();
      case StateManagement.riverpod:
        return _riverpodLoginScreenTest();
    }
  }

  static String _blocLoginScreenTest() => '''
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/common_widgets/common_button.dart';
import '../../../lib/core/common_widgets/common_text_field.dart';
import '../../../lib/core/utils/result.dart';
import '../../../lib/features/demo/domain/entities/user_entity.dart';
import '../../../lib/features/demo/domain/repositories/demo_repository.dart';
import '../../../lib/features/demo/domain/usecases/login_usecase.dart';
import '../../../lib/features/demo/domain/usecases/logout_usecase.dart';
import '../../../lib/features/demo/presentation/bloc/auth_bloc.dart';
import '../../../lib/features/demo/presentation/login_screen.dart';
import '../../../lib/features/settings/presentation/app_settings_cubit.dart';

void main() {
  testWidgets('Login screen renders', (tester) async {
    final repo = _FakeDemoRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AppSettingsCubit()),
            BlocProvider(
              create: (_) => AuthBloc(
                LoginUseCase(repo),
                LogoutUseCase(repo),
              ),
            ),
          ],
          child: const LoginScreen(),
        ),
        locale: const Locale('en'),
      ),
    );
    expect(find.byType(CommonTextField), findsNWidgets(2));
    expect(find.byType(CommonButton), findsNWidgets(2));
  });
}

class _FakeDemoRepository implements DemoRepository {
  @override
  Future<Result<List<UserEntity>>> getUsers() async {
    return const Right(<UserEntity>[]);
  }

  @override
  Future<Result<String>> login(String email, String password) async {
    return const Right('token');
  }

  @override
  Future<Result<void>> logout() async {
    return const Right(null);
  }
}
''';

  static String _getxLoginScreenTest() => '''
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../lib/core/common_widgets/common_button.dart';
import '../../../lib/core/common_widgets/common_text_field.dart';
import '../../../lib/core/utils/result.dart';
import '../../../lib/features/demo/domain/entities/user_entity.dart';
import '../../../lib/features/demo/domain/repositories/demo_repository.dart';
import '../../../lib/features/demo/domain/usecases/login_usecase.dart';
import '../../../lib/features/demo/domain/usecases/logout_usecase.dart';
import '../../../lib/features/demo/presentation/controller/auth_controller.dart';
import '../../../lib/features/demo/presentation/login_screen.dart';
import '../../../lib/features/settings/presentation/app_settings_controller.dart';

void main() {
  setUp(() async {
    final repo = _FakeDemoRepository();
    Get.put(AppSettingsController(), permanent: true);
    Get.put(
      AuthController(LoginUsecase(repo), LogoutUsecase(repo)),
      permanent: true,
    );
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Login screen renders', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: LoginScreen(),
        locale: Locale('en', 'US'),
      ),
    );
    expect(find.byType(CommonTextField), findsNWidgets(2));
    expect(find.byType(CommonButton), findsNWidgets(2));
  });
}

class _FakeDemoRepository implements DemoRepository {
  @override
  Future<Result<List<UserEntity>>> getUsers() async {
    return const Right(<UserEntity>[]);
  }

  @override
  Future<Result<String>> login(String email, String password) async {
    return const Right('token');
  }

  @override
  Future<Result<void>> logout() async {
    return const Right(null);
  }
}
''';

  static String _riverpodLoginScreenTest() => '''
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/common_widgets/common_button.dart';
import '../../../lib/core/common_widgets/common_text_field.dart';
import '../../../lib/core/utils/result.dart';
import '../../../lib/features/demo/domain/entities/user_entity.dart';
import '../../../lib/features/demo/domain/repositories/demo_repository.dart';
import '../../../lib/features/demo/presentation/demo_providers.dart';
import '../../../lib/features/demo/presentation/login_screen.dart';

void main() {
  testWidgets('Login screen renders', (tester) async {
    final repo = _FakeDemoRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          demoRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
          locale: Locale('en'),
        ),
      ),
    );
    expect(find.byType(CommonTextField), findsNWidgets(2));
    expect(find.byType(CommonButton), findsNWidgets(2));
  });
}

class _FakeDemoRepository implements DemoRepository {
  @override
  Future<Result<List<UserEntity>>> getUsers() async {
    return const Right(<UserEntity>[]);
  }

  @override
  Future<Result<String>> login(String email, String password) async {
    return const Right('token');
  }

  @override
  Future<Result<void>> logout() async {
    return const Right(null);
  }
}
''';

  static String userModelTest() => '''
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/features/demo/data/models/user_model.dart';

void main() {
  test('UserModel.fromJson parses values', () {
    final model = UserModel.fromJson({
      'id': 1,
      'name': 'Jane',
      'email': 'jane@example.com',
    });
    expect(model.id, 1);
    expect(model.name, 'Jane');
    expect(model.email, 'jane@example.com');
  });
}
''';

  static String settingsScreenTest(StateManagement state) {
    switch (state) {
      case StateManagement.bloc:
        return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/features/settings/presentation/app_settings_cubit.dart';
import '../../../lib/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets('Settings screen renders', (tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AppSettingsCubit(),
        child: const MaterialApp(
          home: SettingsScreen(),
          locale: Locale('en'),
        ),
      ),
    );
    expect(find.text('Settings'), findsOneWidget);
  });
}
''';
      case StateManagement.getx:
        return '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../lib/features/settings/presentation/app_settings_controller.dart';
import '../../../lib/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets('Settings screen renders', (tester) async {
    Get.put(AppSettingsController(), permanent: true);
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
        locale: Locale('en'),
      ),
    );
    expect(find.text('Settings'), findsOneWidget);
  });
}
''';
      case StateManagement.riverpod:
        return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets('Settings screen renders', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SettingsScreen(),
          locale: Locale('en'),
        ),
      ),
    );
    expect(find.text('Settings'), findsOneWidget);
  });
}
''';
    }
  }
}
