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
    final isSuccess = json['success'] ?? 
                      (json['status'] == 'success') ?? 
                      (json['code'] == 200);
    
    return BaseResponse(
      success: isSuccess,
      message: json['message'] ?? json['msg'] ?? '',
      statusCode: json['code'] ?? json['status_code'],
      errors: json['errors'],
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
}
