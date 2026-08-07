import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Local mirror of `LeadResponse`. `raw` (the full JSON blob) is the source
/// of truth for every field the app actually reads — the other columns
/// exist only so cached reads can be filtered/sorted offline the same way
/// the backend's query params do (`status=`, etc.) without deserializing
/// every row just to filter it.
///
/// `syncState`: `synced` | `pendingCreate` | `pendingUpdate` | `conflict`
/// (Phase 3 - the outbox/sync engine owns writing anything other than
/// `synced` here; Phase 2's read-through-cache repositories only ever
/// write `synced` rows).
class LeadsCache extends Table {
  TextColumn get id => text()();
  TextColumn get companyName => text()();
  TextColumn get contactPerson => text()();
  TextColumn get contactNo => text()();
  TextColumn get status => text()();
  TextColumn get interestLevelId => text().nullable()();
  TextColumn get nextFollowupDate => text().nullable()();
  TextColumn get raw => text()();
  TextColumn get syncState => text().withDefault(const Constant('synced'))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local mirror of `VisitResponse` — same `raw`-is-source-of-truth shape as
/// [LeadsCache].
class VisitsCache extends Table {
  TextColumn get id => text()();
  TextColumn get leadId => text()();
  TextColumn get visitDate => text()();
  TextColumn get scheduledTime => text().nullable()();
  TextColumn get visitType => text()();
  TextColumn get status => text()();
  TextColumn get raw => text()();
  TextColumn get syncState => text().withDefault(const Constant('synced'))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Outbox for offline-queued mutations (Phase 3). `localId` references a
/// [LeadsCache]/[VisitsCache] row's `id` — which may itself still be a
/// `local-<uuid>` placeholder until the parent create syncs and gets
/// rewritten to the server's real UUID (see `core/sync/sync_engine.dart`).
class OutboxEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // 'lead' | 'visit' | 'leaveRequest'
  TextColumn get operation => text()(); // 'create' | 'update' | 'updateStatus'
  TextColumn get localId => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending|inFlight|failed|done
}

@DriftDatabase(tables: [LeadsCache, VisitsCache, OutboxEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // ---- Leads ----

  Future<void> upsertLead({
    required String id,
    required String companyName,
    required String contactPerson,
    required String contactNo,
    required String status,
    String? interestLevelId,
    String? nextFollowupDate,
    required String raw,
    String syncState = 'synced',
  }) {
    return into(leadsCache).insertOnConflictUpdate(
      LeadsCacheCompanion.insert(
        id: id,
        companyName: companyName,
        contactPerson: contactPerson,
        contactNo: contactNo,
        status: status,
        interestLevelId: Value(interestLevelId),
        nextFollowupDate: Value(nextFollowupDate),
        raw: raw,
        syncState: Value(syncState),
        cachedAt: DateTime.now(),
      ),
    );
  }

  Future<LeadsCacheData?> findLeadById(String id) =>
      (select(leadsCache)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<LeadsCacheData>> queryLeads({String? status}) {
    final query = select(leadsCache);
    if (status != null) {
      query.where((t) => t.status.equals(status));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.cachedAt)]);
    return query.get();
  }

  /// Rewrites a locally-created Lead's primary key from its temp id to the
  /// server's real UUID once the outbox drain confirms the create — see
  /// `sync_engine.dart`. Delete+reinsert-under-new-id in one transaction is
  /// simpler and safe at this data volume than trying to `UPDATE` a
  /// primary-key column in place.
  Future<void> reconcileLeadId({required String localId, required String serverId}) {
    return transaction(() async {
      final row = await findLeadById(localId);
      if (row == null) return;
      await (delete(leadsCache)..where((t) => t.id.equals(localId))).go();
      await into(leadsCache).insertOnConflictUpdate(
        LeadsCacheCompanion.insert(
          id: serverId,
          companyName: row.companyName,
          contactPerson: row.contactPerson,
          contactNo: row.contactNo,
          status: row.status,
          interestLevelId: Value(row.interestLevelId),
          nextFollowupDate: Value(row.nextFollowupDate),
          raw: row.raw,
          syncState: const Value('synced'),
          cachedAt: DateTime.now(),
        ),
      );
      // Any Visit rows created offline against the old temp lead id must
      // follow the reconciled id too.
      await (update(visitsCache)..where((t) => t.leadId.equals(localId))).write(
        VisitsCacheCompanion(leadId: Value(serverId)),
      );
    });
  }

  Future<void> markLeadConflict(String id) =>
      (update(leadsCache)..where((t) => t.id.equals(id))).write(
        const LeadsCacheCompanion(syncState: Value('conflict')),
      );

  // ---- Visits ----

  Future<void> upsertVisit({
    required String id,
    required String leadId,
    required String visitDate,
    String? scheduledTime,
    required String visitType,
    required String status,
    required String raw,
    String syncState = 'synced',
  }) {
    return into(visitsCache).insertOnConflictUpdate(
      VisitsCacheCompanion.insert(
        id: id,
        leadId: leadId,
        visitDate: visitDate,
        scheduledTime: Value(scheduledTime),
        visitType: visitType,
        status: status,
        raw: raw,
        syncState: Value(syncState),
        cachedAt: DateTime.now(),
      ),
    );
  }

  Future<List<VisitsCacheData>> queryVisits({String? status, String? leadId}) {
    final query = select(visitsCache);
    if (status != null) query.where((t) => t.status.equals(status));
    if (leadId != null) query.where((t) => t.leadId.equals(leadId));
    query.orderBy([(t) => OrderingTerm.asc(t.visitDate)]);
    return query.get();
  }

  /// Same shape as `reconcileLeadId` — see its doc comment. A Visit's own
  /// id is never referenced elsewhere in this app, so no dependent-row
  /// rewrite is needed here, just the primary-key swap itself.
  Future<void> reconcileVisitId({required String localId, required String serverId}) {
    return transaction(() async {
      final row = await (select(
        visitsCache,
      )..where((t) => t.id.equals(localId))).getSingleOrNull();
      if (row == null) return;
      await (delete(visitsCache)..where((t) => t.id.equals(localId))).go();
      await into(visitsCache).insertOnConflictUpdate(
        VisitsCacheCompanion.insert(
          id: serverId,
          leadId: row.leadId,
          visitDate: row.visitDate,
          scheduledTime: Value(row.scheduledTime),
          visitType: row.visitType,
          status: row.status,
          raw: row.raw,
          syncState: const Value('synced'),
          cachedAt: DateTime.now(),
        ),
      );
    });
  }

  Future<void> markVisitConflict(String id) =>
      (update(visitsCache)..where((t) => t.id.equals(id))).write(
        const VisitsCacheCompanion(syncState: Value('conflict')),
      );

  // ---- Outbox (Phase 3) ----

  Future<int> enqueueOutbox({
    required String entityType,
    required String operation,
    required String localId,
    required String payloadJson,
  }) {
    return into(outboxEntries).insert(
      OutboxEntriesCompanion.insert(
        entityType: entityType,
        operation: operation,
        localId: localId,
        payloadJson: payloadJson,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<List<OutboxEntry>> pendingOutboxInOrder() {
    return (select(
      outboxEntries,
    )..where((t) => t.status.equals('pending'))..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<int> countPendingOutbox() async {
    final rows = await pendingOutboxInOrder();
    return rows.length;
  }

  /// Reactive — the global pending-changes banner watches this directly
  /// (via `StreamProvider`) instead of manually invalidating a
  /// `FutureProvider` after every drain; Drift emits a new count whenever
  /// the underlying table changes.
  Stream<int> watchPendingOutboxCount() {
    final query = select(outboxEntries)..where((t) => t.status.equals('pending'));
    return query.watch().map((rows) => rows.length);
  }

  Stream<bool> watchHasFailedOutbox() {
    final query = select(outboxEntries)..where((t) => t.status.equals('failed'));
    return query.watch().map((rows) => rows.isNotEmpty);
  }

  Stream<String?> watchLeadSyncState(String id) {
    final query = select(leadsCache)..where((t) => t.id.equals(id));
    return query.watchSingleOrNull().map((row) => row?.syncState);
  }

  Stream<String?> watchVisitSyncState(String id) {
    final query = select(visitsCache)..where((t) => t.id.equals(id));
    return query.watchSingleOrNull().map((row) => row?.syncState);
  }

  Future<void> markOutboxInFlight(int id) =>
      (update(outboxEntries)..where((t) => t.id.equals(id))).write(
        const OutboxEntriesCompanion(status: Value('inFlight')),
      );

  /// A network error mid-drain reverts the entry to `pending` (not
  /// `failed`) so the next drain attempt retries it — a plain connectivity
  /// blip is never treated as a real conflict.
  Future<void> resetOutboxToPending(int id) =>
      (update(outboxEntries)..where((t) => t.id.equals(id))).write(
        const OutboxEntriesCompanion(status: Value('pending')),
      );

  Future<void> markOutboxDone(int id) =>
      (update(outboxEntries)..where((t) => t.id.equals(id))).write(
        const OutboxEntriesCompanion(status: Value('done')),
      );

  Future<void> markOutboxFailed(int id, String error) =>
      (update(outboxEntries)..where((t) => t.id.equals(id))).write(
        OutboxEntriesCompanion(status: const Value('failed'), lastError: Value(error)),
      );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'salesmanager_mobile.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
