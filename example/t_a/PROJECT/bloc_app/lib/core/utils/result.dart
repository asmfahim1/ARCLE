import 'package:dartz/dartz.dart';

import 'app_failure.dart';

/// Type alias for Either-based result handling.
/// 
/// Left = Failure, Right = Success
/// 
/// Usage:
/// ```dart
/// Future<Result<User>> getUser(String id) async {
///   try {
///     final user = await api.fetchUser(id);
///     return Right(user);
///   } catch (e) {
///     return Left(AppFailure.fromException(e));
///   }
/// }
/// 
/// // Consuming:
/// final result = await getUser('123');
/// result.fold(
///   (failure) => showError(failure.message),
///   (user) => showUser(user),
/// );
/// ```
typedef Result<T> = Either<AppFailure, T>;

/// Extension methods for Result type
extension ResultExtension<T> on Result<T> {
  /// Returns true if this is a successful result
  bool get isSuccess => isRight();
  
  /// Returns true if this is a failure result
  bool get isFailure => isLeft();
  
  /// Get the success value or null
  T? get valueOrNull => fold((_) => null, (value) => value);
  
  /// Get the failure or null
  AppFailure? get failureOrNull => fold((failure) => failure, (_) => null);
  
  /// Transform success value, preserving failures
  Result<R> mapSuccess<R>(R Function(T value) transform) {
    return fold(
      (failure) => Left(failure),
      (value) => Right(transform(value)),
    );
  }
  
  /// Execute side effect on success
  Result<T> onSuccess(void Function(T value) action) {
    fold((_) {}, action);
    return this;
  }
  
  /// Execute side effect on failure
  Result<T> onFailure(void Function(AppFailure failure) action) {
    fold(action, (_) {});
    return this;
  }
}

/// Helper functions for creating Results
class Results {
  /// Create a successful result
  static Result<T> success<T>(T value) => Right(value);
  
  /// Create a failure result
  static Result<T> failure<T>(AppFailure failure) => Left(failure);
  
  /// Create a failure from exception
  static Result<T> fromException<T>(Object error, [StackTrace? stack]) {
    return Left(AppFailure.fromException(error, stack));
  }
  
  /// Run async operation and wrap in Result
  static Future<Result<T>> guard<T>(Future<T> Function() operation) async {
    try {
      return Right(await operation());
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
