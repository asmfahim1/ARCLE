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
