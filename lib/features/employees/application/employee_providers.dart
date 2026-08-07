import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../data/employee_models.dart';
import '../data/employee_repository.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>(
  (ref) => EmployeeRepository(ref.watch(dioProvider)),
);

/// The signed-in user's own Employee record — there's no `/employees/me`
/// shortcut server-side, so this fetches `GET /employees/{employeeId}`
/// using the id already carried in the auth session.
final currentEmployeeProvider = FutureProvider<EmployeeResponse?>((ref) async {
  final auth = ref.watch(authNotifierProvider).valueOrNull;
  if (auth == null) return null;
  return ref.watch(employeeRepositoryProvider).getById(auth.employeeId);
});
