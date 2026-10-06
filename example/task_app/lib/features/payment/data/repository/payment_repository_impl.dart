import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entity/payment_entity.dart';
import '../../domain/repository/payment_repository.dart';
// import '../model/payment_model.dart';
import '../source/payment_remote_source.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: PaymentRepository)

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._remote);

  final PaymentRemoteSource _remote;

  @override
  Future<Result<List<PaymentEntity>>> getPaymentData() async {
    try {
      final models = await _remote.fetchData();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
