import '../../../../core/utils/result.dart';
import '../entity/payment_entity.dart';

abstract class PaymentRepository {
  Future<Result<List<PaymentEntity>>> getPaymentData();
}
