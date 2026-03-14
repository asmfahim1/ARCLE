import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_users_usecase.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc(this._getUsersUseCase) : super(const UsersState()) {
    on<LoadUsers>(_onLoad);
    on<RefreshUsers>(_onRefresh);
  }

  final GetUsersUseCase _getUsersUseCase;

  Future<void> _onLoad(LoadUsers event, Emitter<UsersState> emit) async {
    emit(state.copyWith(status: UsersStatus.loading, message: null));
    final result = await _getUsersUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        status: UsersStatus.failure,
        message: failure.message,
      )),
      (users) => emit(state.copyWith(
        status: UsersStatus.success,
        users: users,
      )),
    );
  }

  Future<void> _onRefresh(
    RefreshUsers event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(status: UsersStatus.refreshing, message: null));
    final result = await _getUsersUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        status: UsersStatus.failure,
        message: failure.message,
      )),
      (users) => emit(state.copyWith(
        status: UsersStatus.success,
        users: users,
      )),
    );
  }
}
