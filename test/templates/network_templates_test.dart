import 'package:arcle/src/state_management.dart';
import 'package:arcle/src/templates/core/api_templates.dart';
import 'package:arcle/src/templates/core/core_templates.dart';
import 'package:arcle/src/templates/core/di_templates.dart';
import 'package:arcle/src/templates/core/utils_templates.dart';
import 'package:test/test.dart';

void main() {
  group('Network Templates', () {
    test('httpClient template uses package:http and provides ApiHttpClient', () {
      final code = ApiTemplates.httpClient(StateManagement.bloc);
      expect(code, contains("import 'package:http/http.dart' as http;"));
      expect(code, contains('class ApiHttpClient'));
      expect(code, contains('class ApiResponse'));
      expect(code, contains('AbortableRequest'));
      expect(code, contains('AbortableMultipartRequest'));
      expect(code, isNot(contains("package:dio")));
    });

    test('dioClient template uses package:dio', () {
      final code = ApiTemplates.dioClient(StateManagement.bloc);
      expect(code, contains("import 'package:dio/dio.dart';"));
      expect(code, contains('class DioClient'));
    });

    test('utilsFailure for HTTP does not import dio and catches network exceptions', () {
      final code = UtilsTemplates.utilsFailure(NetworkClient.http);
      expect(code, isNot(contains("package:dio")));
      expect(code, contains('ClientException'));
      expect(code, contains('SocketException'));
      expect(code, contains('TimeoutException'));
      expect(code, contains('FormatException'));
    });

    test('utilsFailure for Dio imports dio and handles DioException', () {
      final code = UtilsTemplates.utilsFailure(NetworkClient.dio);
      expect(code, contains("package:dio/dio.dart"));
      expect(code, contains('DioException'));
    });

    test('responseHandler for HTTP uses ApiResponse', () {
      final code = CoreTemplates.responseHandler(NetworkClient.http);
      expect(code, contains('ApiResponse response'));
      expect(code, isNot(contains("package:dio")));
    });

    test('responseHandler for Dio uses Response<dynamic>', () {
      final code = CoreTemplates.responseHandler(NetworkClient.dio);
      expect(code, contains('Response<dynamic> response'));
      expect(code, contains("package:dio/dio.dart"));
    });

    test('errorHandler routes errors to AppDialogs', () {
      final code = CoreTemplates.errorHandler();
      expect(code, contains('AppDialogs.showError'));
      expect(code, contains('AppDialogs.showRetry'));
      expect(code, contains('AppDialogs.showSuccess'));
    });

    test('di template registers ApiHttpClient for http and DioClient for dio', () {
      final httpCode = DiTemplates.di(StateManagement.bloc, NetworkClient.http);
      expect(httpCode, contains('ApiHttpClient'));
      expect(httpCode, isNot(contains('DioClient')));

      final dioCode = DiTemplates.di(StateManagement.bloc, NetworkClient.dio);
      expect(dioCode, contains('DioClient'));
      expect(dioCode, isNot(contains('ApiHttpClient')));
    });
  });
}
