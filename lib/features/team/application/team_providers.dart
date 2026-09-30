import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../data/team_models.dart';
import '../data/team_repository.dart';

final teamRepositoryProvider = Provider<TeamRepository>(
  (ref) => TeamRepository(ref.watch(dioProvider)),
);

final teamProgressProvider = FutureProvider.autoDispose<List<TeamMemberProgress>>((ref) {
  return ref.watch(teamRepositoryProvider).getTeamProgress();
});
