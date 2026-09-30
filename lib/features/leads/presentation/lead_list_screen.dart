import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/colors.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/sync/sync_state_chip.dart';
import '../../masters/application/master_data_providers.dart';
import '../../masters/data/master_data_models.dart';
import '../application/lead_providers.dart';
import '../data/lead_models.dart';

const _filterChips = <String?, String>{
  null: 'All',
  LeadStatus.interested: 'Interested',
  LeadStatus.negotiation: 'Negotiation',
  LeadStatus.contacted: 'Contacted',
  LeadStatus.closedWon: 'Closed Won',
  LeadStatus.lost: 'Lost',
  LeadStatus.lapsed: 'Lapsed',
};

class LeadListScreen extends ConsumerWidget {
  const LeadListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(leadListFilterProvider);
    final leadsAsync = ref.watch(leadListProvider);
    final interestCodes = ref.watch(masterDataCodeMapProvider(MasterType.interestLevel));
    final lostReasonLabels = ref.watch(masterDataLabelMapProvider(MasterType.lostReason));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: TextField(
              decoration: const InputDecoration(
                isDense: true,
                prefixIcon: Icon(Icons.search, size: 20),
                hintText: 'Search company or contact',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => ref.read(leadListFilterProvider.notifier).state = filter
                  .copyWith(search: value),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                for (final entry in _filterChips.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(entry.value),
                      selected: filter.status == entry.key,
                      onSelected: (_) => ref.read(leadListFilterProvider.notifier).state = filter
                          .copyWith(status: entry.key, clearStatus: entry.key == null),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(leadListProvider.future),
              child: leadsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(error is ApiException ? error.message : 'Something went wrong.'),
                ),
                data: (page) {
                  if (page.content.isEmpty) {
                    return ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('No leads match this filter.')),
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: page.content.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final lead = page.content[index];
                      return _LeadCard(
                        lead: lead,
                        interestCode: interestCodes[lead.interestLevelId],
                        lostReasonLabel: lead.lostReasonId != null
                            ? lostReasonLabels[lead.lostReasonId]
                            : lead.lostReasonOther,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/leads/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _LeadCard extends ConsumerWidget {
  const _LeadCard({required this.lead, this.interestCode, this.lostReasonLabel});

  final LeadResponse lead;
  final String? interestCode;
  final String? lostReasonLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColors = AppColors.leadStatusChip(lead.status);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/leads/${lead.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lead.companyName, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(lead.contactPerson, style: Theme.of(context).textTheme.bodySmall),
                        LeadSyncStateChip(leadId: lead.id),
                      ],
                    ),
                  ),
                  if (lead.isLost)
                    Chip(
                      label: const Text('UNASSIGNED – LOST'),
                      labelStyle: TextStyle(color: statusColors.fg, fontWeight: FontWeight.w700),
                      backgroundColor: statusColors.bg,
                      side: BorderSide.none,
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (interestCode != null) ...[
                          CircleAvatar(radius: 4, backgroundColor: AppColors.interestDotColor(interestCode)),
                          const SizedBox(width: 6),
                        ],
                        Chip(
                          label: Text(LeadStatus.label(lead.status)),
                          labelStyle: TextStyle(color: statusColors.fg, fontWeight: FontWeight.w700),
                          backgroundColor: statusColors.bg,
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                lead.isLost
                    ? 'Lost reason: ${lostReasonLabel ?? '—'}'
                    : 'Next follow-up: ${lead.nextFollowupDate ?? '—'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
