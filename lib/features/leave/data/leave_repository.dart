import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/sync/outbox_models.dart';
import 'leave_models.dart';

const _uuid = Uuid();

/// No local read-cache for Leave (unlike Lead/Visit) — a queued create is
/// still safely durable via the outbox (it syncs once connectivity
/// returns, same reliability guarantee), it just isn't optimistically
/// shown in "My Requests" until it does. The app-wide sync banner already
/// surfaces "N changes waiting to sync" for it in the meantime, which is
/// enough visibility for v1 without a second Drift cache table.
class LeaveRepository {
  LeaveRepository(this._dio, this._db);

  final Dio _dio;
  final AppDatabase _db;

  Future<List<LeaveBalanceResponse>> getBalances({int? year}) async {
    try {
      final response = await _dio.get(
        '/leave-balances/mine',
        queryParameters: {if (year != null) 'year': year},
      );
      return (response.data as List<dynamic>)
          .map((e) => LeaveBalanceResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<LeaveRequestResponse>> listMine({String? status}) async {
    try {
      final response = await _dio.get(
        '/leave-requests/mine',
        queryParameters: {if (status != null) 'status': status, 'size': 50},
      );
      final content = (response.data as Map<String, dynamic>)['content'] as List<dynamic>;
      return content.map((e) => LeaveRequestResponse.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<LeaveTypeResponse>> getLeaveTypes() async {
    try {
      final response = await _dio.get('/leave-types');
      return (response.data as List<dynamic>)
          .map((e) => LeaveTypeResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<LeaveRequestResponse> createOnline(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post('/leave-requests', data: payload);
      return LeaveRequestResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> createQueued(LeaveRequestCreateRequest request) async {
    final tempId = '$localIdPrefix${_uuid.v4()}';
    await _db.enqueueOutbox(
      entityType: OutboxEntityType.leaveRequest,
      operation: OutboxOperation.create,
      localId: tempId,
      payloadJson: jsonEncode(request.toJson()),
    );
  }
}
