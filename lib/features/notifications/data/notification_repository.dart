import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/paged.dart';
import 'notification_models.dart';

class NotificationRepository {
  NotificationRepository(this._dio);

  final Dio _dio;

  Future<Paged<NotificationResponse>> list({
    bool unreadOnly = false,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {'unreadOnly': unreadOnly, 'page': page, 'size': size},
      );
      return Paged.fromJson(response.data as Map<String, dynamic>, NotificationResponse.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<int> unreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count');
      return (response.data as Map<String, dynamic>)['count'] as int? ?? 0;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _dio.patch('/notifications/$id/read');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.patch('/notifications/read-all');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
