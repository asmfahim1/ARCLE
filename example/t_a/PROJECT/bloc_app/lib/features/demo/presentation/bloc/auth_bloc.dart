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
