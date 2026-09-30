import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/session_controller.dart';
import '../../../core/storage/secure_token_store.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(plainDioProvider)),
);

/// `null` state means "logged out." Hydrated from secure storage at boot so
/// a warm start doesn't flash a login screen before the stored session is
/// checked - go_router's redirect (see app.dart) waits on this provider's
/// `isLoading` before making its first routing decision.
class AuthNotifier extends AsyncNotifier<AuthState?> {
  @override
  Future<AuthState?> build() async {
    // React to forced logouts from AuthInterceptor (401 that survives
    // refresh) - see core/network/session_controller.dart's doc comment for
    // why this is a plain tick counter rather than a direct interceptor
    // callback into this class.
    ref.listen<int>(sessionExpiredProvider, (previous, next) {
      if (previous != null && next != previous) {
        state = const AsyncData(null);
      }
    });

    final tokenStore = ref.watch(secureTokenStoreProvider);
    return tokenStore.read();
  }

  Future<void> login({required String email, required String password}) async {
    final tokenStore = ref.read(secureTokenStoreProvider);
    final repository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final auth = await repository.login(email: email, password: password);
      await tokenStore.write(auth);
      return auth;
    });
  }

  Future<void> logout() async {
    final tokenStore = ref.read(secureTokenStoreProvider);
    final repository = ref.read(authRepositoryProvider);
    final current = await tokenStore.read();
    if (current != null) {
      await repository.logout(current.refreshToken);
    }
    await tokenStore.clear();
    state = const AsyncData(null);
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthState?>(AuthNotifier.new);

/// Derived convenience flag for go_router's redirect logic and simple UI
/// checks (e.g. gating Team Progress nav on entitlements happens elsewhere,
/// but "is there a session at all" is this).
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).valueOrNull != null;
});
