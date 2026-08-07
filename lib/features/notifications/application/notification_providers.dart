import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/paged.dart';
import '../../auth/application/auth_providers.dart';
import '../data/notification_models.dart';
import '../data/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(ref.watch(dioProvider)),
);

/// The 30-second poll is the reliable baseline for the unread badge
/// regardless of push notifications — this provider is intentionally NOT
/// `autoDispose` so it keeps polling for the whole authenticated session,
/// not just while the Home screen (where the badge is shown) happens to be
/// mounted. On a transient fetch failure it keeps the last known count
/// rather than flashing the badge to 0.
class UnreadCountNotifier extends AsyncNotifier<int> {
  Timer? _timer;

  @override
  Future<int> build() async {
    final auth = ref.watch(authNotifierProvider).valueOrNull;
    ref.onDispose(() => _timer?.cancel());

    _timer?.cancel();
    if (auth == null) return 0;

    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
    return _fetch();
  }

  Future<int> _fetch() => ref.read(notificationRepositoryProvider).unreadCount();

  Future<void> _refresh() async {
    try {
      final count = await _fetch();
      state = AsyncData(count);
    } catch (_) {
      // Keep whatever was last shown - a blip shouldn't flash the badge.
    }
  }

  /// Called by the Notifications screen right after a successful mark-read
  /// action, so the badge updates immediately rather than waiting for the
  /// next 30s tick.
  Future<void> refreshNow() => _refresh();

  void setCount(int value) => state = AsyncData(value);
}

final unreadNotificationCountProvider = AsyncNotifierProvider<UnreadCountNotifier, int>(
  UnreadCountNotifier.new,
);

class NotificationListFilter {
  const NotificationListFilter({this.unreadOnly = false});

  final bool unreadOnly;
}

final notificationListFilterProvider = StateProvider<NotificationListFilter>(
  (ref) => const NotificationListFilter(),
);

final notificationListProvider = FutureProvider.autoDispose<Paged<NotificationResponse>>((ref) {
  final filter = ref.watch(notificationListFilterProvider);
  return ref.watch(notificationRepositoryProvider).list(unreadOnly: filter.unreadOnly, size: 50);
});
