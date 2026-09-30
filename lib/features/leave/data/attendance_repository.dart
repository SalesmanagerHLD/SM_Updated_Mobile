import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import 'attendance_models.dart';

/// Deliberately NEVER routed through the offline outbox, unlike every
/// other write in this app — the server stamps `checkInAt`/`checkOutAt` at
/// request-receipt time, so queuing-and-replaying-later would silently
/// record the wrong time. Offline clock-in/out fails fast with a clear
/// "you're offline" error instead (see the confirmed scope carve-out in
/// the mobile app plan).
class AttendanceRepository {
  AttendanceRepository(this._dio);

  final Dio _dio;

  Future<AttendanceRecordResponse> clockIn() async {
    try {
      final response = await _dio.post('/attendance/clock-in');
      return AttendanceRecordResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AttendanceRecordResponse> clockOut() async {
    try {
      final response = await _dio.post('/attendance/clock-out');
      return AttendanceRecordResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<AttendanceDayResponse>> mine({String? yearMonth}) async {
    try {
      final response = await _dio.get(
        '/attendance/mine',
        queryParameters: {if (yearMonth != null) 'yearMonth': yearMonth},
      );
      return (response.data as List<dynamic>)
          .map((e) => AttendanceDayResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
