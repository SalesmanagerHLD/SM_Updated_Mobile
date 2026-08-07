import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../application/team_providers.dart';
import '../data/team_models.dart';

class TeamProgressScreen extends ConsumerWidget {
  const TeamProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(teamProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Team Progress')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(teamProgressProvider.future),
        child: progressAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(error is ApiException ? error.message : 'Something went wrong.'),
          ),
          data: (members) {
            if (members.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No team members to show.')),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: members.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _MemberCard(member: members[index]),
            );
          },
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});

  final TeamMemberProgress member;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/team/${member.employeeId}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      member.initials,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.employeeName, style: Theme.of(context).textTheme.titleSmall),
                        Text(
                          member.lastActivityAt != null ? 'Last active ${member.lastActivityAt}' : 'No recent activity',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _MiniStat(label: 'Leads', value: member.totalLeads)),
                  Expanded(
                    child: _MiniStat(
                      label: 'Due Today',
                      value: member.visitsDueToday,
                      color: const Color(0xFFB54708),
                    ),
                  ),
                  Expanded(
                    child: _MiniStat(label: 'Won', value: member.wonCount, color: const Color(0xFF12805C)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, this.color});

  final String label;
  final int value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}
