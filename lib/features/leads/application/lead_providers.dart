import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/paged.dart';
import '../../../core/storage/storage_providers.dart';
import '../data/lead_models.dart';
import '../data/lead_repository.dart';

final leadRepositoryProvider = Provider<LeadRepository>(
  (ref) => LeadRepository(ref.watch(dioProvider), ref.watch(appDatabaseProvider)),
);

/// Leads list screen state: status filter + free-text search, refetched
/// whenever either changes.
class LeadListFilter {
  const LeadListFilter({this.status, this.search});

  final String? status;
  final String? search;

  LeadListFilter copyWith({String? status, bool clearStatus = false, String? search}) =>
      LeadListFilter(
        status: clearStatus ? null : (status ?? this.status),
        search: search ?? this.search,
      );
}

final leadListFilterProvider = StateProvider<LeadListFilter>((ref) => const LeadListFilter());

final leadListProvider = FutureProvider.autoDispose<Paged<LeadResponse>>((ref) async {
  final filter = ref.watch(leadListFilterProvider);
  final repository = ref.watch(leadRepositoryProvider);
  return repository.list(LeadQuery(status: filter.status, search: filter.search, size: 50));
});

final leadDetailProvider = FutureProvider.autoDispose.family<LeadResponse, String>((ref, id) {
  return ref.watch(leadRepositoryProvider).getById(id);
});
