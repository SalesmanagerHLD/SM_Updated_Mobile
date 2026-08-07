import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/paged.dart';
import '../data/activity_models.dart';
import '../data/activity_repository.dart';

final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => ActivityRepository(ref.watch(dioProvider)),
);

final leadActivityProvider = FutureProvider.autoDispose.family<Paged<ActivityResponse>, String>((
  ref,
  leadId,
) {
  return ref.watch(activityRepositoryProvider).list(leadId: leadId);
});
