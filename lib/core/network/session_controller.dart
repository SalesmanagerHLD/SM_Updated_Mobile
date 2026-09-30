import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A plain tick counter bumped by [AuthInterceptor] whenever a request comes
/// back 401 and refresh fails (or there's no session to refresh). Lives in
/// `core/network` with no knowledge of `features/auth` so the interceptor
/// never has to import feature code — `AuthNotifier` listens to this tick
/// and reacts by clearing its own state, keeping the dependency one-directional
/// (features depend on core, never the reverse).
class SessionExpiredNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void notifyExpired() => state++;
}

final sessionExpiredProvider = NotifierProvider<SessionExpiredNotifier, int>(
  SessionExpiredNotifier.new,
);
