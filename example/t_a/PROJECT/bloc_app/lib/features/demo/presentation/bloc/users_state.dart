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
