  import 'package:dartz/dartz.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:get/get.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  
  import '../../../lib/core/common_widgets/common_button.dart';
  import '../../../lib/core/common_widgets/common_text_field.dart';
  import '../../../lib/core/utils/result.dart';
  import '../../../lib/core/session_manager/pref_manager.dart';
  import '../../../lib/features/demo/domain/entities/user_entity.dart';
import '../../../lib/features/demo/domain/repositories/demo_repository.dart';
import '../../../lib/features/demo/domain/usecases/login_usecase.dart';
import '../../../lib/features/demo/domain/usecases/logout_usecase.dart';
import '../../../lib/features/demo/presentation/controller/auth_controller.dart';
import '../../../lib/features/demo/presentation/pages/login_screen.dart';
import '../../../lib/features/settings/presentation/app_settings_controller.dart';

  void main() {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      Get.put(PrefManager(), permanent: true);
      final repo = _FakeDemoRepository();
      Get.put(AppSettingsController(), permanent: true);
      Get.put(
      AuthController(LoginUseCase(repo), LogoutUseCase(repo)),
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
