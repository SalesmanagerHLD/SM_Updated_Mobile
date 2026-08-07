import 'dart:convert';

import '../network/api_exception.dart';
import '../storage/app_database.dart';
import 'outbox_models.dart';

// Repositories are constructed by Riverpod (see sync_providers.dart) and
// injected here as plain interfaces this file depends on directly, to keep
// the engine testable without a ProviderContainer.
import '../../features/leads/data/lead_repository.dart';
import '../../features/leave/data/leave_repository.dart';
import '../../features/visits/data/visit_repository.dart';

/// Drains the offline outbox: dispatches queued mutations in `createdAt`
/// order, reconciles temp ids to server UUIDs, and marks genuine conflicts
/// for the UI to surface — the one genuinely novel piece of this app, no
/// direct web-app equivalent to port.
///
/// Conflict policy is deliberately simple (confirmed scope, not an
/// oversight): **server wins, surface a banner** — no field-level
/// merge/CRDT. A network error reverts the entry to `pending` and stops
/// the drain (we probably just went offline mid-loop); a real rejection
/// (409/422/anything else non-network) marks the entry `failed` and the
/// cached record `conflict`, for the UI's "this changed on the server —
/// Discard my change / Retry" banner.
///
/// Known v1 limitation: the Lead→Visit temp-id rewrite (see
/// [_rewritePayload]) only works within a single `drainOnce()` run's
/// lifetime (an in-memory map) — if the app is killed between a Lead's
/// create syncing and its dependent Visit's create syncing, the Visit's
/// queued payload still references the old local id and the dependent
/// create will fail, surfacing as a conflict rather than silently
/// corrupting data. Acceptable for v1; revisit only if this proves to be a
/// real problem in practice.
class SyncEngine {
  SyncEngine({
    required AppDatabase db,
    required LeadRepository leadRepository,
    required VisitRepository visitRepository,
    required LeaveRepository leaveRepository,
  }) : _db = db,
       _leadRepository = leadRepository,
       _visitRepository = visitRepository,
       _leaveRepository = leaveRepository;

  final AppDatabase _db;
  final LeadRepository _leadRepository;
  final VisitRepository _visitRepository;
  final LeaveRepository _leaveRepository;

  bool _running = false;
  final Map<String, String> _reconciledLeadIds = {};

  bool get isRunning => _running;

  Future<void> drainOnce() async {
    if (_running) return;
    _running = true;
    try {
      final pending = await _db.pendingOutboxInOrder();
      for (final entry in pending) {
        final shouldStop = await _processEntry(entry);
        if (shouldStop) break;
      }
    } finally {
      _running = false;
    }
  }

  /// Returns true if the drain loop should stop (a network error - we
  /// probably just went offline mid-loop, no point attempting the rest).
  Future<bool> _processEntry(OutboxEntry entry) async {
    await _db.markOutboxInFlight(entry.id);
    final payload = _rewritePayload(entry);

    try {
      switch ((entry.entityType, entry.operation)) {
        case (OutboxEntityType.lead, OutboxOperation.create):
          final response = await _leadRepository.createOnline(payload);
          await _db.reconcileLeadId(localId: entry.localId, serverId: response.id);
          _reconciledLeadIds[entry.localId] = response.id;
        case (OutboxEntityType.lead, OutboxOperation.updateStatus):
          await _leadRepository.updateStatusOnline(_resolveLeadId(entry.localId), payload);
        case (OutboxEntityType.visit, OutboxOperation.create):
          final response = await _visitRepository.createOnline(payload);
          await _db.reconcileVisitId(localId: entry.localId, serverId: response.id);
        case (OutboxEntityType.visit, OutboxOperation.update):
          await _visitRepository.updateOnline(entry.localId, payload);
        case (OutboxEntityType.leaveRequest, OutboxOperation.create):
          await _leaveRepository.createOnline(payload);
        default:
          throw StateError('Unhandled outbox entry ${entry.entityType}/${entry.operation}');
      }
      await _db.markOutboxDone(entry.id);
      return false;
    } on ApiException catch (e) {
      if (e.isNetworkError) {
        await _db.resetOutboxToPending(entry.id);
        return true;
      }
      await _db.markOutboxFailed(entry.id, e.message);
      await _markConflict(entry);
      return false;
    }
  }

  Future<void> _markConflict(OutboxEntry entry) async {
    if (entry.entityType == OutboxEntityType.lead) {
      await _db.markLeadConflict(_resolveLeadId(entry.localId));
    } else if (entry.entityType == OutboxEntityType.visit) {
      await _db.markVisitConflict(entry.localId);
    }
  }

  String _resolveLeadId(String id) => _reconciledLeadIds[id] ?? id;

  /// Rewrites a `leadId` field in a queued Visit's payload if it still
  /// references a temp id that's since been reconciled to a real server
  /// UUID within this drain run.
  Map<String, dynamic> _rewritePayload(OutboxEntry entry) {
    final payload = jsonDecode(entry.payloadJson) as Map<String, dynamic>;
    final leadId = payload['leadId'];
    if (leadId is String && isLocalId(leadId) && _reconciledLeadIds.containsKey(leadId)) {
      payload['leadId'] = _reconciledLeadIds[leadId];
    }
    return payload;
  }
}
