import 'package:dartz/dartz.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  
  import '../../../lib/core/common_widgets/common_button.dart';
  import '../../../lib/core/common_widgets/common_text_field.dart';
  import '../../../lib/core/di/injection.dart';
  import '../../../lib/core/utils/result.dart';
  import '../../../lib/features/demo/domain/entities/user_entity.dart';
  import '../../../lib/features/demo/domain/repositories/demo_repository.dart';
  import '../../../lib/features/demo/domain/usecases/login_usecase.dart';
  import '../../../lib/features/demo/domain/usecases/logout_usecase.dart';
  import '../../../lib/features/demo/presentation/pages/login_screen.dart';
  
  void main() {
    testWidgets('Login screen renders', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repo = _FakeDemoRepository();
      await getIt.reset();
      getIt
        ..registerLazySingleton<LoginUseCase>(() => LoginUseCase(repo))
        ..registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(repo));
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
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
