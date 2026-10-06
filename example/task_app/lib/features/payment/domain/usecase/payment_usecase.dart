import '../../../../core/utils/result.dart';
import '../entity/payment_entity.dart';
import '../repository/payment_repository.dart';
import 'package:injectable/injectable.dart';


@injectable

class PaymentUseCase {
  PaymentUseCase(this._repo);

  final PaymentRepository _repo;

  Future<Result<List<PaymentEntity>>> call() {
    return _repo.getPaymentData();
  }
}
