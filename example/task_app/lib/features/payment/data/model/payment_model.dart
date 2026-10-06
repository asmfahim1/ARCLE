import '../../domain/entity/payment_entity.dart';

class PaymentModel {

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }
  PaymentModel({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  PaymentEntity toEntity() {
    return PaymentEntity(id: id, title: title);
  }
}
