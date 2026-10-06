import 'package:equatable/equatable.dart';
import '../../domain/entity/payment_entity.dart';

enum PaymentStatus { initial, loading, success, failure }

class PaymentState extends Equatable {
  const PaymentState({
    this.status = PaymentStatus.initial,
    this.items = const [],
    this.message,
  });

  final PaymentStatus status;
  final List<PaymentEntity> items;
  final String? message;

  PaymentState copyWith({
    PaymentStatus? status,
    List<PaymentEntity>? items,
    String? message,
  }) {
    return PaymentState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
