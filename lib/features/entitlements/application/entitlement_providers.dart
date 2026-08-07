import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../data/entitlement_repository.dart';

final entitlementRepositoryProvider = Provider<EntitlementRepository>(
  (ref) => EntitlementRepository(ref.watch(dioProvider)),
);

/// Fetched once per session, right after auth resolves; re-fetches
/// automatically on login/logout since it watches [authNotifierProvider].
/// Screens gate nav items/routes on this the same way the web app's
/// `EntitlementContext` does — hidden entirely when absent, never just
/// disabled.
final entitlementsProvider = FutureProvider<Set<String>>((ref) async {
  final auth = ref.watch(authNotifierProvider).valueOrNull;
  if (auth == null) return const {};
  return ref.watch(entitlementRepositoryProvider).getMyEntitlements();
});

final hasEntitlementProvider = Provider.family<bool, String>((ref, entitlement) {
  return ref.watch(entitlementsProvider).valueOrNull?.contains(entitlement) ?? false;
});
