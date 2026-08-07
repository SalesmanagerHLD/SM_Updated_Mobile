import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/colors.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/paged.dart';
import '../../activity/application/activity_providers.dart';
import '../../activity/data/activity_models.dart';
import '../../employees/application/employee_providers.dart';
import '../../leads/application/lead_providers.dart';
import '../../leads/data/lead_models.dart';
import '../../leads/data/lead_repository.dart';

/// Read-only drill-down for a single team member, reached from Team
/// Progress — assigned leads + recent activity, nothing editable or
/// further clickable (matches the web app's own "list only" scope
/// decision: leads aren't individually tappable here). No new backend
/// endpoint needed: `GET /leads?ownerId=` and `GET /activity?ownerId=`
/// already scope correctly for whoever is allowed to view this page.
class TeamMemberDetailScreen extends ConsumerWidget {
  const TeamMemberDetailScreen({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeeRepositoryProvider).getById(employeeId);
    return Scaffold(
      appBar: AppBar(title: const Text('Team Member')),
      body: FutureBuilder(
        future: employeeAsync,
        builder: (context, snapshot) {
          final name = snapshot.data?.fullName;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (name != null) ...[
                Text(name, style: Theme.of(context).textTheme.headlineSmall),
                Text(
                  "Read-only view of this team member's leads and activity.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
              ],
              Text('Assigned Leads', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              _AssignedLeadsSection(employeeId: employeeId),
              const SizedBox(height: 20),
              Text('Recent Activity', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              _RecentActivitySection(employeeId: employeeId),
            ],
          );
        },
      ),
    );
  }
}

class _AssignedLeadsSection extends ConsumerWidget {
  const _AssignedLeadsSection({required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(_teamMemberLeadsProvider(employeeId));
    return leadsAsync.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
      error: (error, _) => Text(error is ApiException ? error.message : 'Something went wrong.'),
      data: (leads) {
        if (leads.isEmpty) return const Text('No leads assigned yet.');
        return Card(
          child: Column(
            children: [
              for (final lead in leads)
                _LeadRow(lead: lead, isLast: lead == leads.last),
            ],
          ),
        );
      },
    );
  }
}

class _LeadRow extends StatelessWidget {
  const _LeadRow({required this.lead, required this.isLast});

  final LeadResponse lead;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.leadStatusChip(lead.status);
    return Column(
      children: [
        ListTile(
          title: Text(lead.companyName),
          subtitle: Text(lead.contactPerson),
          trailing: Chip(
            label: Text(LeadStatus.label(lead.status)),
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

class _RecentActivitySection extends ConsumerWidget {
  const _RecentActivitySection({required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(_teamMemberActivityProvider(employeeId));
    return activityAsync.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
      error: (_, _) => const SizedBox.shrink(),
      data: (page) {
        if (page.content.isEmpty) return const Text('No activity yet.');
        return Column(
          children: [
            for (final entry in page.content)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: CircleAvatar(radius: 4, backgroundColor: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.description),
                          Text(
                            '${entry.companyName} · ${entry.createdAt}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

final _teamMemberLeadsProvider = FutureProvider.autoDispose.family<List<LeadResponse>, String>((
  ref,
  employeeId,
) async {
  final repository = ref.watch(leadRepositoryProvider);
  final page = await repository.list(LeadQuery(ownerId: employeeId, size: 100));
  return page.content;
});

final _teamMemberActivityProvider = FutureProvider.autoDispose.family<Paged<ActivityResponse>, String>(
  (ref, employeeId) => ref.watch(activityRepositoryProvider).list(ownerId: employeeId),
);
