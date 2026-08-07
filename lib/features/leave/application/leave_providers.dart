import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/storage/storage_providers.dart';
import '../data/attendance_models.dart';
import '../data/attendance_repository.dart';
import '../data/leave_models.dart';
import '../data/leave_repository.dart';

final leaveRepositoryProvider = Provider<LeaveRepository>(
  (ref) => LeaveRepository(ref.watch(dioProvider), ref.watch(appDatabaseProvider)),
);

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => AttendanceRepository(ref.watch(dioProvider)),
);

final leaveBalancesProvider = FutureProvider.autoDispose<List<LeaveBalanceResponse>>((ref) {
  return ref.watch(leaveRepositoryProvider).getBalances();
});

final myLeaveRequestsProvider = FutureProvider.autoDispose<List<LeaveRequestResponse>>((ref) {
  return ref.watch(leaveRepositoryProvider).listMine();
});

final leaveTypesProvider = FutureProvider.autoDispose<List<LeaveTypeResponse>>((ref) {
  return ref.watch(leaveRepositoryProvider).getLeaveTypes();
});

/// Today's attendance status, derived from the current month's calendar
/// (there's no dedicated "today" endpoint — `GET /attendance/mine` returns
/// the derived day-by-day calendar for the month, todays's entry is just
/// the last one when the month is the current one).
final todayAttendanceProvider = FutureProvider.autoDispose<AttendanceDayResponseOrNull>((ref) async {
  final days = await ref.watch(attendanceRepositoryProvider).mine();
  final todayIso = _isoDate(DateTime.now());
  for (final day in days) {
    if (day.date == todayIso) return AttendanceDayResponseOrNull(day);
  }
  return const AttendanceDayResponseOrNull(null);
});

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// Riverpod's `AsyncValue` already models "no value yet" via loading/error
/// states, but "loaded, and there's genuinely no record for today" is a
/// third, valid outcome distinct from both — this tiny wrapper makes that
/// explicit instead of overloading `null` in a way that's ambiguous with
/// "still loading."
class AttendanceDayResponseOrNull {
  const AttendanceDayResponseOrNull(this.value);

  final AttendanceDayResponse? value;
}
