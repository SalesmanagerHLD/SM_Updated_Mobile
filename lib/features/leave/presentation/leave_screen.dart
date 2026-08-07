import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/colors.dart';
import '../../../core/network/api_exception.dart';
import '../../entitlements/application/entitlement_providers.dart';
import '../../entitlements/data/entitlement_repository.dart';
import '../application/leave_providers.dart';
import '../data/leave_models.dart';

class LeaveScreen extends ConsumerWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitled = ref.watch(hasEntitlementProvider(FeatureEntitlement.employeeLeaveManagement));

    if (!entitled) {
      return Scaffold(
        appBar: AppBar(title: const Text('Leave & Attendance')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              "Leave & Attendance isn't enabled for your organization.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Leave & Attendance')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayAttendanceProvider);
          ref.invalidate(leaveBalancesProvider);
          ref.invalidate(myLeaveRequestsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _TodayAttendanceCard(),
            const SizedBox(height: 20),
            Text('Leave Balance', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            const _LeaveBalanceRow(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Requests', style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () => context.push('/leave/request'),
                  child: const Text('+ Request Leave'),
                ),
              ],
            ),
            const _MyRequestsList(),
          ],
        ),
      ),
    );
  }
}

class _TodayAttendanceCard extends ConsumerWidget {
  const _TodayAttendanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayAttendanceProvider);
    final today = todayAsync.valueOrNull?.value;
    final isClockedIn = today?.checkInAt != null && today?.checkOutAt == null;
    final isDone = today?.checkOutAt != null;

    return Card(
      color: const Color(0xFF12151B),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatToday(),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDone ? 'Clocked out' : (isClockedIn ? 'Clocked in' : 'Not clocked in'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ],
              ),
            ),
            if (!isDone)
              FilledButton(
                onPressed: () async {
                  final repository = ref.read(attendanceRepositoryProvider);
                  try {
                    if (isClockedIn) {
                      await repository.clockOut();
                    } else {
                      await repository.clockIn();
                    }
                    ref.invalidate(todayAttendanceProvider);
                  } on ApiException catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                    }
                  }
                },
                child: Text(isClockedIn ? 'Clock Out' : 'Clock In'),
              ),
          ],
        ),
      ),
    );
  }

  String _formatToday() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Today, ${months[now.month - 1]} ${now.day}';
  }
}

class _LeaveBalanceRow extends ConsumerWidget {
  const _LeaveBalanceRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balancesAsync = ref.watch(leaveBalancesProvider);
    return balancesAsync.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
      error: (error, _) => Text(error is ApiException ? error.message : 'Something went wrong.'),
      data: (balances) {
        if (balances.isEmpty) {
          return const Text('No leave types configured.');
        }
        return Row(
          children: [
            for (final balance in balances) ...[
              Expanded(child: _BalanceCard(balance: balance)),
              if (balance != balances.last) const SizedBox(width: 8),
            ],
          ],
        );
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final LeaveBalanceResponse balance;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                children: [
                  TextSpan(text: '${balance.remainingDays}'),
                  TextSpan(
                    text: '/${balance.totalAllocated}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(balance.leaveTypeName, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _MyRequestsList extends ConsumerWidget {
  const _MyRequestsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(myLeaveRequestsProvider);
    return requestsAsync.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
      error: (error, _) => Text(error is ApiException ? error.message : 'Something went wrong.'),
      data: (requests) {
        if (requests.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No leave requests yet.'),
          );
        }
        return Card(
          child: Column(
            children: [
              for (final request in requests)
                _RequestRow(request: request, isLast: request == requests.last),
            ],
          ),
        );
      },
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({required this.request, required this.isLast});

  final LeaveRequestResponse request;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.leaveStatusChip(request.status);
    return Column(
      children: [
        ListTile(
          title: Text('${request.startDate} – ${request.endDate}'),
          subtitle: request.reason != null ? Text(request.reason!) : null,
          trailing: Chip(
            label: Text(request.status),
            labelStyle: TextStyle(color: colors.fg, fontWeight: FontWeight.w700, fontSize: 11),
            backgroundColor: colors.bg,
            side: BorderSide.none,
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}
