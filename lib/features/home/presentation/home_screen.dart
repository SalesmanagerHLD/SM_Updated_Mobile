import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/colors.dart';
import '../../../core/network/api_exception.dart';
import '../../employees/application/employee_providers.dart';
import '../../leads/data/lead_models.dart';
import '../../masters/application/master_data_providers.dart';
import '../../masters/data/master_data_models.dart';
import '../../notifications/application/notification_providers.dart';
import '../../visits/data/visit_models.dart';
import '../application/home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendaAsync = ref.watch(homeAgendaProvider);
    final employeeAsync = ref.watch(currentEmployeeProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_greeting(employeeAsync.valueOrNull?.firstName)),
        actions: [
          IconButton(
            tooltip: unreadCount > 0 ? '$unreadCount unread notifications' : 'Notifications',
            icon: Badge(
              label: Text('$unreadCount'),
              isLabelVisible: unreadCount > 0,
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(homeAgendaProvider.future),
        child: agendaAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(error: error, onRetry: () => ref.invalidate(homeAgendaProvider)),
          data: (agenda) => _HomeContent(agenda: agenda),
        ),
      ),
    );
  }

  String _greeting(String? firstName) {
    final hour = DateTime.now().hour;
    final timeOfDay = hour < 12 ? 'morning' : (hour < 17 ? 'afternoon' : 'evening');
    final name = firstName == null ? '' : ', $firstName';
    return 'Good $timeOfDay$name';
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.agenda});

  final HomeAgenda agenda;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purposeLabels = ref.watch(masterDataLabelMapProvider(MasterType.visitPurpose));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: "Today's Follow-ups",
                value: agenda.todayFollowUps.length,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Lapsed Calls',
                value: agenda.lapsedLeads.length,
                color: AppColors.leadStatusChip(LeadStatus.lost).fg,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Follow-ups (7d)',
                value: agenda.upcomingFollowUps.length,
                color: AppColors.leaveStatusChip('APPROVED').fg,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (agenda.todayFollowUps.isNotEmpty) ...[
          _SectionHeader(title: "Today's Follow-ups"),
          Card(
            child: Column(
              children: [
                for (final visit in agenda.todayFollowUps)
                  _VisitRow(
                    visit: visit,
                    purposeLabel: purposeLabels[visit.purposeId] ?? visit.purposeOther,
                    isLast: visit == agenda.todayFollowUps.last,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (agenda.lapsedLeads.isNotEmpty) ...[
          _SectionHeader(title: 'Lapsed Calls'),
          Card(
            child: Column(
              children: [
                for (final lead in agenda.lapsedLeads)
                  _LapsedLeadRow(lead: lead, isLast: lead == agenda.lapsedLeads.last),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        _SectionHeader(title: 'Upcoming Follow-ups'),
        if (agenda.upcomingFollowUps.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Nothing scheduled in the next 7 days.'),
          )
        else
          Card(
            child: Column(
              children: [
                for (final visit in agenda.upcomingFollowUps)
                  _VisitRow(
                    visit: visit,
                    purposeLabel: purposeLabels[visit.purposeId] ?? visit.purposeOther,
                    isLast: visit == agenda.upcomingFollowUps.last,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _VisitRow extends StatelessWidget {
  const _VisitRow({required this.visit, required this.purposeLabel, required this.isLast});

  final VisitResponse visit;
  final String? purposeLabel;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(purposeLabel ?? VisitType.label(visit.visitType)),
          subtitle: Text(
            '${visit.visitDate}${visit.scheduledTime != null ? ' · ${visit.scheduledTime}' : ''} · ${VisitType.label(visit.visitType)}',
          ),
          onTap: () => context.push('/leads/${visit.leadId}'),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}

class _LapsedLeadRow extends StatelessWidget {
  const _LapsedLeadRow({required this.lead, required this.isLast});

  final LeadResponse lead;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 4,
            backgroundColor: AppColors.leadStatusChip(LeadStatus.lost).fg,
          ),
          title: Text(lead.companyName),
          subtitle: Text(
            lead.nextFollowupDate != null
                ? 'No follow-up since ${lead.nextFollowupDate}'
                : lead.contactPerson,
          ),
          onTap: () => context.push('/leads/${lead.id}'),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is ApiException ? (error as ApiException).message : 'Something went wrong.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
