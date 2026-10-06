import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/payment_usecase.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc(this._useCase) : super(const PaymentState()) {
    on<LoadPayment>(_onLoad);
    add(const LoadPayment());
  }

  final PaymentUseCase _useCase;

  Future<void> _onLoad(
    LoadPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: PaymentStatus.loading));
    final result = await _useCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PaymentStatus.failure,
          message: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: PaymentStatus.success,
          items: data,
        ),
      ),
    );
  }
}
