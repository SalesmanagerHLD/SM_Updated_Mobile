import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/storage/storage_providers.dart';
import '../data/visit_repository.dart';

final visitRepositoryProvider = Provider<VisitRepository>(
  (ref) => VisitRepository(ref.watch(dioProvider), ref.watch(appDatabaseProvider)),
);
