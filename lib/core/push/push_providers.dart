import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/entitlements/application/entitlement_providers.dart';
import '../../features/entitlements/data/entitlement_repository.dart';
import '../network/network_providers.dart';
import 'device_token_repository.dart';
import 'push_navigation.dart';
import 'push_service.dart';

final deviceTokenRepositoryProvider = Provider<DeviceTokenRepository>(
  (ref) => DeviceTokenRepository(ref.watch(dioProvider)),
);

final pushServiceProvider = Provider<PushService>((ref) {
  final service = PushService(deviceTokenRepository: ref.watch(deviceTokenRepositoryProvider));
  service.onNotificationTapped = (route) => ref.read(pushTapRouteProvider.notifier).navigateTo(route);
  return service;
});

/// Initializes push exactly once the caller is both authenticated and the
/// org has `PUSH_NOTIFICATIONS` entitled — mirrors the web app's
/// `usePushNotifications` hook's own gating. A logout doesn't tear this
/// down (the token stays registered; `AuthNotifier.logout()` doesn't call
/// `unregisterCurrentToken()` in v1 — acceptable since a stale token just
/// stops receiving pushes silently, and re-registering on next login is
/// idempotent server-side).
class PushCoordinator extends Notifier<void> {
  @override
  void build() {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isEntitled = ref.watch(hasEntitlementProvider(FeatureEntitlement.pushNotifications));
    if (isAuthenticated && isEntitled) {
      ref.read(pushServiceProvider).initialize();
    }
  }
}

final pushCoordinatorProvider = NotifierProvider<PushCoordinator, void>(PushCoordinator.new);
