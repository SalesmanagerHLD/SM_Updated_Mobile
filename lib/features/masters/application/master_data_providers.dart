import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../data/master_data_models.dart';
import '../data/master_data_repository.dart';

final masterDataRepositoryProvider = Provider<MasterDataRepository>(
  (ref) => MasterDataRepository(ref.watch(dioProvider)),
);

/// Master data rarely changes within a session, so this is deliberately NOT
/// `autoDispose` — once a type is fetched it stays cached for the app's
/// lifetime (matching the read-cache spirit of the offline design without
/// needing a dedicated Drift table for it in v1; add one later only if a
/// real "browse masters fully offline on cold start" need shows up).
final masterDataProvider = FutureProvider.family<List<MasterDataItem>, String>((ref, type) {
  return ref.watch(masterDataRepositoryProvider).list(type);
});

/// Convenience: label lookup by id for a given master type, e.g. resolving
/// a Lead's `interestLevelId` to "Hot" for display.
final masterDataLabelMapProvider = Provider.family<Map<String, String>, String>((ref, type) {
  final items = ref.watch(masterDataProvider(type)).valueOrNull ?? const [];
  return {for (final item in items) item.id: item.label};
});

/// Convenience: code lookup by id, e.g. checking whether a Lead's
/// `interestLevelId` resolves to the `HOT` code (business logic keys off
/// the code, never the admin-editable label).
final masterDataCodeMapProvider = Provider.family<Map<String, String>, String>((ref, type) {
  final items = ref.watch(masterDataProvider(type)).valueOrNull ?? const [];
  return {for (final item in items) item.id: item.code};
});
