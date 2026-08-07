abstract class OutboxEntityType {
  static const lead = 'lead';
  static const visit = 'visit';

  /// Leave request submission has no timing dependency (unlike Attendance
  /// clock-in/out, which is deliberately NEVER routed through the outbox —
  /// see `AttendanceRepository`'s doc comment), so it safely goes through
  /// the same offline queue as Lead/Visit creates.
  static const leaveRequest = 'leaveRequest';
}

abstract class OutboxOperation {
  static const create = 'create';
  static const update = 'update';
  static const updateStatus = 'updateStatus';
}

/// Local-id prefix for an offline-created record not yet reconciled to its
/// server UUID — see `sync_engine.dart`.
const localIdPrefix = 'local-';

bool isLocalId(String id) => id.startsWith(localIdPrefix);
