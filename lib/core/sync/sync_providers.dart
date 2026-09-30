import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/storage_providers.dart';
import '../../features/leads/application/lead_providers.dart';
import '../../features/leave/application/leave_providers.dart';
import '../../features/visits/application/visit_providers.dart';
import 'connectivity_service.dart';
import 'sync_engine.dart';

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(
    db: ref.watch(appDatabaseProvider),
    leadRepository: ref.watch(leadRepositoryProvider),
    visitRepository: ref.watch(visitRepositoryProvider),
    leaveRepository: ref.watch(leaveRepositoryProvider),
  );
});

/// Reactive counts driving the global sync banner — see
/// `AppDatabase.watchPendingOutboxCount`/`watchHasFailedOutbox`.
final pendingOutboxCountProvider = StreamProvider<int>((ref) {
  return ref.watch(appDatabaseProvider).watchPendingOutboxCount();
});

final hasFailedOutboxProvider = StreamProvider<bool>((ref) {
  return ref.watch(appDatabaseProvider).watchHasFailedOutbox();
});

final leadSyncStateProvider = StreamProvider.family<String?, String>((ref, leadId) {
  return ref.watch(appDatabaseProvider).watchLeadSyncState(leadId);
});

final visitSyncStateProvider = StreamProvider.family<String?, String>((ref, visitId) {
  return ref.watch(appDatabaseProvider).watchVisitSyncState(visitId);
});

/// Starts draining automatically whenever connectivity is (re)established.
/// Kept alive for the app's lifetime (not `autoDispose`) via [main.dart]
/// eagerly reading it once at startup — see that file's comment.
class SyncCoordinator extends Notifier<void> {
  @override
  void build() {
    ref.listen<AsyncValue<bool>>(isOnlineProvider, (previous, next) {
      final wasOffline = previous?.valueOrNull != true;
      final isOnlineNow = next.valueOrNull == true;
      if (wasOffline && isOnlineNow) {
        ref.read(syncEngineProvider).drainOnce();
      }
    });
    // Also attempt a drain immediately at startup, in case there are
    // leftover pending entries from a previous session that never synced.
    Future.microtask(() => ref.read(syncEngineProvider).drainOnce());
  }

  Future<void> syncNow() => ref.read(syncEngineProvider).drainOnce();
}

final syncCoordinatorProvider = NotifierProvider<SyncCoordinator, void>(SyncCoordinator.new);
