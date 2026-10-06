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
