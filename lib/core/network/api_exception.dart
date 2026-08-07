import 'package:dio/dio.dart';

/// Normalizes a raw [DioException] into something the UI can render directly,
/// mirroring the shape the backend's global `@ControllerAdvice` returns
/// (`{status, message, fieldErrors[]}`) — same role as the web app's
/// `parseApiError` helper.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors,
    this.isNetworkError = false,
  });

  final String message;
  final int? statusCode;
  final Map<String, String>? fieldErrors;
  final bool isNetworkError;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isFeatureNotEntitled =>
      statusCode == 403 && message.contains('FEATURE_NOT_ENTITLED');

  factory ApiException.fromDioException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ApiException(
        message: 'No connection — check your network and try again.',
        isNetworkError: true,
      );
    }

    final response = e.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] as String? ?? data['error'] as String?;
      final rawFieldErrors = data['fieldErrors'];
      Map<String, String>? fieldErrors;
      if (rawFieldErrors is List) {
        fieldErrors = {
          for (final entry in rawFieldErrors)
            if (entry is Map && entry['field'] != null)
              entry['field'].toString(): entry['message']?.toString() ?? 'Invalid value',
        };
      } else if (rawFieldErrors is Map) {
        fieldErrors = rawFieldErrors.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
      return ApiException(
        message: message ?? _fallbackMessage(statusCode),
        statusCode: statusCode,
        fieldErrors: fieldErrors,
      );
    }

    return ApiException(message: _fallbackMessage(statusCode), statusCode: statusCode);
  }

  static String _fallbackMessage(int? statusCode) => switch (statusCode) {
    401 => 'Your session has expired — please sign in again.',
    403 => "You don't have permission to do that.",
    404 => 'Not found.',
    409 => 'That conflicts with the current state — please refresh and try again.',
    _ => 'Something went wrong. Please try again.',
  };

  @override
  String toString() => message;
}
