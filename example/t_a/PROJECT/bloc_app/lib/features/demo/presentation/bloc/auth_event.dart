  import 'package:equatable/equatable.dart';
  
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
    const LoginSubmitted(this.email, this.password);
  
    final String email;
    final String password;

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
