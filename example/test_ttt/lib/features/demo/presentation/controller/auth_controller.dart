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
