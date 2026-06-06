class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    dynamic json,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final bool success = json['success'] as bool? ?? false;
      final String message = json['message']?.toString() ?? '';
      final dynamic data = json['data'];

      if (!success) {
        return ApiResponse(success: false, message: message);
      }

      return ApiResponse(
        success: true,
        message: message,
        data: fromJson != null && data != null ? fromJson(data) : null,
        statusCode: 200,
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  factory ApiResponse.success(T data, {String message = 'Success'}) {
    return ApiResponse(
        success: true, message: message, data: data, statusCode: 200);
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
        success: false, message: message, statusCode: statusCode);
  }
}
