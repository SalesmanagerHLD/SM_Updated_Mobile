import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_token_store.dart';
import 'dio_client.dart';
import 'session_controller.dart';

final secureTokenStoreProvider = Provider<SecureTokenStore>((ref) => SecureTokenStore());

/// No interceptors — for `/auth/*` endpoints only. See `dio_client.dart`.
final plainDioProvider = Provider<Dio>((ref) => buildPlainDio());

/// The authenticated client every domain repository (Leads, Visits, Leave,
/// Notifications, ...) should depend on. A 401 that survives refresh bumps
/// [sessionExpiredProvider] rather than reaching into `features/auth`
/// directly — see that file's doc comment for why.
final dioProvider = Provider<Dio>((ref) {
  final tokenStore = ref.watch(secureTokenStoreProvider);
  final refreshDio = ref.watch(plainDioProvider);
  return buildAuthenticatedDio(
    tokenStore: tokenStore,
    refreshDio: refreshDio,
    onUnauthenticated: () async {
      ref.read(sessionExpiredProvider.notifier).notifyExpired();
    },
  );
});
