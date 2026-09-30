import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/paged.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/sync/outbox_models.dart';
import 'visit_models.dart';

const _uuid = Uuid();

bool _isNetworkError(DioException e) =>
    e.type == DioExceptionType.connectionError ||
    e.type == DioExceptionType.connectionTimeout ||
    e.type == DioExceptionType.receiveTimeout;

class VisitRepository {
  VisitRepository(this._dio, this._db);

  final Dio _dio;
  final AppDatabase _db;

  /// `GET /visits/today` — NOT paged, owner-scoped today-or-earlier PLANNED
  /// visits. The main data source for the Home agenda.
  Future<List<VisitResponse>> today() async {
    try {
      final response = await _dio.get('/visits/today');
      final visits = (response.data as List<dynamic>)
          .map((e) => VisitResponse.fromJson(e as Map<String, dynamic>))
          .toList();
      for (final visit in visits) {
        await _upsertCache(visit);
      }
      return visits;
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        final cached = await _db.queryVisits(status: VisitStatus.planned);
        final today = DateTime.now();
        final todayStr = _dateOnly(today);
        return cached
            .map(_fromRow)
            .where((v) => v.visitDate.compareTo(todayStr) <= 0)
            .toList();
      }
      throw ApiException.fromDioException(e);
    }
  }

  Future<Paged<VisitResponse>> list({
    String? leadId,
    String? status,
    String? dateFrom,
    String? dateTo,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/visits',
        queryParameters: {
          if (leadId != null) 'leadId': leadId,
          if (status != null) 'status': status,
          if (dateFrom != null) 'dateFrom': dateFrom,
          if (dateTo != null) 'dateTo': dateTo,
          'page': page,
          'size': size,
        },
      );
      final result = Paged.fromJson(response.data as Map<String, dynamic>, VisitResponse.fromJson);
      for (final visit in result.content) {
        await _upsertCache(visit);
      }
      return result;
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        final cached = await _db.queryVisits(status: status, leadId: leadId);
        var visits = cached.map(_fromRow).toList();
        if (dateFrom != null) visits = visits.where((v) => v.visitDate.compareTo(dateFrom) >= 0).toList();
        if (dateTo != null) visits = visits.where((v) => v.visitDate.compareTo(dateTo) <= 0).toList();
        return Paged.fromCacheList(visits);
      }
      throw ApiException.fromDioException(e);
    }
  }

  /// Advisory-only, never queued/cached.
  Future<List<VisitSameDayMatch>> checkSameDay({required String leadId, required String visitDate}) async {
    try {
      final response = await _dio.get(
        '/visits/same-day',
        queryParameters: {'leadId': leadId, 'visitDate': visitDate},
      );
      return (response.data as List<dynamic>)
          .map((e) => VisitSameDayMatch.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<VisitResponse> createOnline(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post('/visits', data: payload);
      final visit = VisitResponse.fromJson(response.data as Map<String, dynamic>);
      await _upsertCache(visit);
      return visit;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<VisitResponse> updateOnline(String visitId, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.put('/visits/$visitId', data: payload);
      final visit = VisitResponse.fromJson(response.data as Map<String, dynamic>);
      await _upsertCache(visit);
      return visit;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Every Visit create goes through the outbox, even when online — same
  /// rationale as `LeadRepository#createQueued`. If [request.leadId] is
  /// still a local (unsynced) temp id, `SyncEngine` rewrites this entry's
  /// stored payload to the real server id once the parent Lead's own create
  /// entry resolves — outbox entries always drain in `createdAt` order, so
  /// the parent is guaranteed to be attempted first.
  Future<String> createQueued(VisitCreateRequest request) async {
    final tempId = '$localIdPrefix${_uuid.v4()}';
    final placeholder = {...request.toJson(), 'id': tempId, 'organizationId': '', 'status': request.status ?? VisitStatus.planned};
    await _db.upsertVisit(
      id: tempId,
      leadId: request.leadId,
      visitDate: request.visitDate,
      scheduledTime: request.scheduledTime,
      visitType: request.visitType,
      status: request.status ?? VisitStatus.planned,
      raw: jsonEncode(placeholder),
      syncState: 'pendingCreate',
    );
    await _db.enqueueOutbox(
      entityType: OutboxEntityType.visit,
      operation: OutboxOperation.create,
      localId: tempId,
      payloadJson: jsonEncode(request.toJson()),
    );
    return tempId;
  }

  Future<VisitResponse> updateStatusOnline(String visitId, String status) async {
    try {
      final response = await _dio.patch('/visits/$visitId/status', data: {'status': status});
      final visit = VisitResponse.fromJson(response.data as Map<String, dynamic>);
      await _upsertCache(visit);
      return visit;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> _upsertCache(VisitResponse visit) => _db.upsertVisit(
    id: visit.id,
    leadId: visit.leadId,
    visitDate: visit.visitDate,
    scheduledTime: visit.scheduledTime,
    visitType: visit.visitType,
    status: visit.status,
    raw: jsonEncode(visit.toJson()),
  );

  VisitResponse _fromRow(dynamic row) =>
      VisitResponse.fromJson(jsonDecode(row.raw as String) as Map<String, dynamic>);

  String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
