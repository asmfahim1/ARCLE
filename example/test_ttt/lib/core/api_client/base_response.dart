/// Generic base response wrapper for API responses.
/// 
/// Handles common response patterns:
/// ```json
/// { "success": true, "message": "OK", "data": {...} }
/// { "status": "success", "data": [...] }
/// ```
class BaseResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const BaseResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.errors,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    final rawSuccess = json['success'];
    final isSuccess = rawSuccess is bool
        ? rawSuccess
        : (json['status']?.toString().toLowerCase() == 'success' ||
            _asInt(json['code']) == 200);
    final rawErrors = json['errors'];
    final parsedErrors = rawErrors is Map<String, dynamic>
        ? rawErrors
        : rawErrors is Map
            ? rawErrors.map(
                (key, value) => MapEntry(key.toString(), value),
              )
            : null;
    
    return BaseResponse(
      success: isSuccess,
      message: _asString(json['message']) ?? _asString(json['msg']) ?? '',
      statusCode: _asInt(json['code']) ?? _asInt(json['status_code']),
      errors: parsedErrors,
      data: (json['data'] != null && fromJsonT != null)
          ? fromJsonT(json['data'])
          : null,
    );
  }
  
  /// Create a successful response
  factory BaseResponse.success(T data, {String message = 'Success'}) {
    return BaseResponse(success: true, message: message, data: data);
  }
  
  /// Create a failed response
  factory BaseResponse.failure(String message, {int? statusCode}) {
    return BaseResponse(success: false, message: message, statusCode: statusCode);
  }
  
  /// Check if response has validation errors
  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;
  
  /// Get first validation error message
  String? get firstError {
    if (errors == null || errors!.isEmpty) return null;
    final firstField = errors!.values.first;
    if (firstField is List && firstField.isNotEmpty) {
      return firstField.first.toString();
    }
    return firstField.toString();
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _asString(dynamic value) {
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    return null;
  }
}
