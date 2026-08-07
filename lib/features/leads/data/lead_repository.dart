import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/paged.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/sync/outbox_models.dart';
import 'lead_models.dart';

const _uuid = Uuid();

bool _isNetworkError(DioException e) =>
    e.type == DioExceptionType.connectionError ||
    e.type == DioExceptionType.connectionTimeout ||
    e.type == DioExceptionType.receiveTimeout;

/// Query params for `GET /leads` — mirrors the backend's filter set. Only
/// the ones this app's screens actually use are exposed; the backend
/// supports more (interestLevelId, stateId, cityId, productId, dateFrom,
/// dateTo) that nothing here needs yet.
class LeadQuery {
  const LeadQuery({this.status, this.search, this.ownerId, this.page = 0, this.size = 20});

  final String? status;
  final String? search;
  final String? ownerId;
  final int page;
  final int size;

  Map<String, dynamic> toQueryParams() => {
    if (status != null) 'status': status,
    if (search != null && search!.isNotEmpty) 'search': search,
    if (ownerId != null) 'ownerId': ownerId,
    'page': page,
    'size': size,
  };
}

/// Read-through-cache + outbox-aware writes, the pattern every domain
/// repository in this app follows: network-first reads that upsert into
/// Drift on success and fall back to the local cache on a network error
/// (tagging the result `fromCache: true` so the UI can show a staleness
/// caption); writes are queued through the outbox (Phase 3) so the UI has
/// one code path regardless of connectivity.
class LeadRepository {
  LeadRepository(this._dio, this._db);

  final Dio _dio;
  final AppDatabase _db;

  Future<Paged<LeadResponse>> list(LeadQuery query) async {
    try {
      final response = await _dio.get('/leads', queryParameters: query.toQueryParams());
      final page = Paged.fromJson(
        response.data as Map<String, dynamic>,
        LeadResponse.fromJson,
      );
      for (final lead in page.content) {
        await _upsertCache(lead);
      }
      return page;
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        final cached = await _db.queryLeads(status: query.status);
        return Paged.fromCacheList(cached.map((row) => _fromRow(row)).toList());
      }
      throw ApiException.fromDioException(e);
    }
  }

  Future<LeadResponse> getById(String id) async {
    try {
      final response = await _dio.get('/leads/$id');
      final lead = LeadResponse.fromJson(response.data as Map<String, dynamic>);
      await _upsertCache(lead);
      return lead;
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        final cached = await _db.findLeadById(id);
        if (cached != null) return _fromRow(cached);
      }
      throw ApiException.fromDioException(e);
    }
  }

  /// Advisory-only, never queued/cached — if unreachable, the caller just
  /// skips the duplicate warning (this never blocks lead creation).
  Future<List<LeadDuplicateMatch>> checkDuplicates({String? contactNo, String? companyName}) async {
    try {
      final response = await _dio.get(
        '/leads/duplicates',
        queryParameters: {
          if (contactNo != null && contactNo.isNotEmpty) 'contactNo': contactNo,
          if (companyName != null && companyName.isNotEmpty) 'companyName': companyName,
        },
      );
      return (response.data as List<dynamic>)
          .map((e) => LeadDuplicateMatch.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Fires the create immediately against the network — called both by
  /// [createQueued] when already online (so the perceived latency of the
  /// common "online the whole time" case is unchanged) and by `SyncEngine`
  /// when it drains a queued `create` entry.
  Future<LeadResponse> createOnline(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post('/leads', data: payload);
      final lead = LeadResponse.fromJson(response.data as Map<String, dynamic>);
      await _upsertCache(lead);
      return lead;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<LeadResponse> updateStatusOnline(String leadId, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.patch('/leads/$leadId/status', data: payload);
      final lead = LeadResponse.fromJson(response.data as Map<String, dynamic>);
      await _upsertCache(lead);
      return lead;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Every Lead create goes through the outbox, even when online — one code
  /// path regardless of connectivity. `SyncEngine` drains it immediately if
  /// already online (see the enqueue-time trigger it registers), so this
  /// doesn't add perceptible latency for the common case.
  Future<String> createQueued(LeadCreateRequest request) async {
    final tempId = '$localIdPrefix${_uuid.v4()}';
    final placeholder = {
      ...request.toJson(),
      'id': tempId,
      'organizationId': '',
      'status': LeadStatus.newStatus,
    };
    await _db.upsertLead(
      id: tempId,
      companyName: request.companyName,
      contactPerson: request.contactPerson,
      contactNo: request.contactNo,
      status: LeadStatus.newStatus,
      interestLevelId: request.interestLevelId,
      nextFollowupDate: request.nextFollowupDate,
      raw: jsonEncode(placeholder),
      syncState: 'pendingCreate',
    );
    await _db.enqueueOutbox(
      entityType: OutboxEntityType.lead,
      operation: OutboxOperation.create,
      localId: tempId,
      payloadJson: jsonEncode(request.toJson()),
    );
    return tempId;
  }

  Future<void> updateStatusQueued(String leadId, LeadStatusUpdateRequest request) async {
    final existing = await _db.findLeadById(leadId);
    if (existing != null) {
      final json = jsonDecode(existing.raw) as Map<String, dynamic>;
      json['status'] = request.status;
      if (request.lostReasonId != null) json['lostReasonId'] = request.lostReasonId;
      if (request.lostReasonOther != null) json['lostReasonOther'] = request.lostReasonOther;
      await _db.upsertLead(
        id: existing.id,
        companyName: json['companyName'] as String? ?? existing.companyName,
        contactPerson: json['contactPerson'] as String? ?? existing.contactPerson,
        contactNo: json['contactNo'] as String? ?? existing.contactNo,
        status: request.status,
        interestLevelId: json['interestLevelId'] as String?,
        nextFollowupDate: json['nextFollowupDate'] as String?,
        raw: jsonEncode(json),
        syncState: 'pendingUpdate',
      );
    }
    await _db.enqueueOutbox(
      entityType: OutboxEntityType.lead,
      operation: OutboxOperation.updateStatus,
      localId: leadId,
      payloadJson: jsonEncode(request.toJson()),
    );
  }

  Future<void> _upsertCache(LeadResponse lead) => _db.upsertLead(
    id: lead.id,
    companyName: lead.companyName,
    contactPerson: lead.contactPerson,
    contactNo: lead.contactNo,
    status: lead.status,
    interestLevelId: lead.interestLevelId,
    nextFollowupDate: lead.nextFollowupDate,
    raw: jsonEncode(lead.toJson()),
  );

  LeadResponse _fromRow(LeadsCacheData row) =>
      LeadResponse.fromJson(jsonDecode(row.raw) as Map<String, dynamic>);
}
