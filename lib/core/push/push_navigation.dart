import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A tapped push notification signals where to navigate through this
/// tiny event-bus provider rather than `PushService` importing `app.dart`'s
/// `goRouterProvider` directly — same one-directional-dependency reasoning
/// as `core/network/session_controller.dart`. `SalesManagerApp` (which
/// already holds the router instance) listens and clears it after acting.
class PushTapRouteNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void navigateTo(String route) => state = route;

  void clear() => state = null;
}

final pushTapRouteProvider = NotifierProvider<PushTapRouteNotifier, String?>(
  PushTapRouteNotifier.new,
);
