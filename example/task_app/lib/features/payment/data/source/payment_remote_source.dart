import '../../../../core/api_client/api_service.dart';
import '../../../../core/session_manager/session_manager.dart';
import '../../../../core/utils/endpoints.dart';
import 'package:injectable/injectable.dart';

import '../model/payment_model.dart';

@lazySingleton

class PaymentRemoteSource {
  PaymentRemoteSource(this._api, this._session);

  final ApiService _api;
  final SessionManager _session;

  Future<List<PaymentModel>> fetchData() async {
    final token = await _session.getToken();
    final response = await _api.get(ApiEndpoints.paymentList, query: {
      'token': token ?? '',
    });

    final data = (response.data as List<dynamic>? ?? []);
    return data
        .map((item) => PaymentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
