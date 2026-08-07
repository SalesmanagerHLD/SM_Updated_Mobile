import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/design/colors.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/sync/sync_state_chip.dart';
import '../../activity/application/activity_providers.dart';
import '../../attachments/application/attachment_providers.dart';
import '../../masters/application/master_data_providers.dart';
import '../../masters/data/master_data_models.dart';
import '../application/lead_providers.dart';
import '../data/lead_models.dart';

class LeadDetailScreen extends ConsumerWidget {
  const LeadDetailScreen({super.key, required this.leadId});

  final String leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadAsync = ref.watch(leadDetailProvider(leadId));

    return Scaffold(
      appBar: AppBar(),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(leadDetailProvider(leadId).future),
        child: leadAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(error is ApiException ? error.message : 'Something went wrong.'),
          ),
          data: (lead) => _LeadDetailBody(lead: lead),
        ),
      ),
    );
  }
}

class _LeadDetailBody extends ConsumerStatefulWidget {
  const _LeadDetailBody({required this.lead});

  final LeadResponse lead;

  @override
  ConsumerState<_LeadDetailBody> createState() => _LeadDetailBodyState();
}

class _LeadDetailBodyState extends ConsumerState<_LeadDetailBody> {
  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    final businessTypeLabels = ref.watch(masterDataLabelMapProvider(MasterType.businessType));
    final cityLabels = ref.watch(masterDataLabelMapProvider(MasterType.city));
    final stateLabels = ref.watch(masterDataLabelMapProvider(MasterType.state));
    final productLabels = ref.watch(masterDataLabelMapProvider(MasterType.product));
    final industryLabels = ref.watch(masterDataLabelMapProvider(MasterType.industry));
    final leadSourceLabels = ref.watch(masterDataLabelMapProvider(MasterType.leadSource));
    final interestCodes = ref.watch(masterDataCodeMapProvider(MasterType.interestLevel));
    final interestLabels = ref.watch(masterDataLabelMapProvider(MasterType.interestLevel));

    final statusColors = AppColors.leadStatusChip(lead.status);
    final interestCode = interestCodes[lead.interestLevelId];
    final cityState = [
      lead.cityId != null ? cityLabels[lead.cityId] : lead.cityOther,
      lead.stateId != null ? stateLabels[lead.stateId] : lead.stateOther,
    ].where((e) => e != null && e.isNotEmpty).join(', ');
    final products = lead.productIds.map((id) => productLabels[id]).whereType<String>().join(', ');

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(LeadStatus.label(lead.status)),
                    labelStyle: TextStyle(color: statusColors.fg, fontWeight: FontWeight.w700),
                    backgroundColor: statusColors.bg,
                    side: BorderSide.none,
                  ),
                  const SizedBox(width: 8),
                  LeadSyncStateChip(leadId: lead.id),
                  if (interestCode != null) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text((lead.interestLevelId != null
                              ? interestLabels[lead.interestLevelId]
                              : lead.interestLevelOther) ??
                          interestCode),
                      labelStyle: TextStyle(
                        color: AppColors.interestDotColor(interestCode),
                        fontWeight: FontWeight.w700,
                      ),
                      backgroundColor: AppColors.interestDotColor(interestCode).withValues(alpha: 0.12),
                      side: BorderSide.none,
                    ),
                  ],
                  if (lead.isLost) ...[
                    const SizedBox(width: 8),
                    Text('Unassigned – available for reassignment', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(lead.companyName, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(
                lead.designationId != null || lead.designationOther != null
                    ? '${lead.contactPerson} · ${lead.designationOther ?? ''}'
                    : lead.contactPerson,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              _SectionLabel('Required Details'),
              Card(
                child: Column(
                  children: [
                    _KeyValueRow('Business Type', lead.businessTypeId != null
                        ? businessTypeLabels[lead.businessTypeId]
                        : lead.businessTypeOther),
                    _KeyValueRow('Contact Number', lead.contactNo),
                    _KeyValueRow('City, State', cityState.isEmpty ? null : cityState),
                    _KeyValueRow('Product', products.isEmpty ? null : products),
                    _KeyValueRow('Next Follow-up', lead.nextFollowupDate),
                    _KeyValueRow('Expected Closure', lead.expectedCloseDate, isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ExpansionTile(
                  title: const Text('Additional Details'),
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  children: [
                    _KeyValueRow('Industry', lead.industryId != null ? industryLabels[lead.industryId] : lead.industryOther),
                    _KeyValueRow('Lead Source', lead.leadSourceId != null ? leadSourceLabels[lead.leadSourceId] : lead.leadSourceOther),
                    _KeyValueRow('Turnover', lead.turnover?.toString()),
                    _KeyValueRow('Email', lead.email),
                    _KeyValueRow('Address', lead.address),
                    _KeyValueRow('Current Product/Solution', lead.currentProductSolution),
                    _KeyValueRow('Budget Range', lead.budgetRange, isLast: true),
                  ],
                ),
              ),
              if (lead.remarks != null && lead.remarks!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _SectionLabel('Remarks'),
                Card(child: Padding(padding: const EdgeInsets.all(14), child: Text(lead.remarks!))),
              ],
              const SizedBox(height: 20),
              _SectionLabel('Attachments'),
              _AttachmentsSection(leadId: lead.id),
              const SizedBox(height: 20),
              _SectionLabel('Activity'),
              _ActivitySection(leadId: lead.id),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                if (!lead.isLost)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => _showMarkAsLostDialog(context, ref, lead.id),
                      child: const Text('Mark as Lost'),
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.push('/leads/${lead.id}/visits/new'),
                    child: const Text('Log Visit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _showMarkAsLostDialog(BuildContext context, WidgetRef ref, String leadId) async {
  final reasons = ref.read(masterDataProvider(MasterType.lostReason)).valueOrNull ?? const [];
  String? selectedReasonId;
  final otherController = TextEditingController();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: const Text('Mark as Lost'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedReasonId,
              decoration: const InputDecoration(labelText: 'Lost Reason'),
              isExpanded: true,
              items: [
                const DropdownMenuItem(value: null, child: Text('—')),
                for (final reason in reasons) DropdownMenuItem(value: reason.id, child: Text(reason.label)),
              ],
              onChanged: (v) => setDialogState(() => selectedReasonId = v),
            ),
            if (selectedReasonId == null) ...[
              const SizedBox(height: 8),
              TextField(
                controller: otherController,
                decoration: const InputDecoration(labelText: 'Or type a reason'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (selectedReasonId == null && otherController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Pick or enter a lost reason')),
                );
                return;
              }
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Mark as Lost'),
          ),
        ],
      ),
    ),
  );

  if (confirmed == true) {
    await ref.read(leadRepositoryProvider).updateStatusQueued(
      leadId,
      LeadStatusUpdateRequest(
        status: LeadStatus.lost,
        lostReasonId: selectedReasonId,
        lostReasonOther: selectedReasonId == null ? otherController.text.trim() : null,
      ),
    );
    ref.invalidate(leadDetailProvider(leadId));
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.outline,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow(this.label, this.value, {this.isLast = false});

  final String label;
  final String? value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Flexible(
                child: Text(
                  value ?? '—',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}

class _AttachmentsSection extends ConsumerStatefulWidget {
  const _AttachmentsSection({required this.leadId});

  final String leadId;

  @override
  ConsumerState<_AttachmentsSection> createState() => _AttachmentsSectionState();
}

class _AttachmentsSectionState extends ConsumerState<_AttachmentsSection> {
  bool _uploading = false;

  Future<void> _pickAndUpload(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      await ref
          .read(attachmentRepositoryProvider)
          .upload(widget.leadId, filePath: picked.path, fileName: picked.name);
      ref.invalidate(leadAttachmentsProvider(widget.leadId));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _showAddSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take Photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _pickAndUpload(source);
  }

  Future<void> _delete(String attachmentId) async {
    try {
      await ref.read(attachmentRepositoryProvider).delete(attachmentId);
      ref.invalidate(leadAttachmentsProvider(widget.leadId));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final attachmentsAsync = ref.watch(leadAttachmentsProvider(widget.leadId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        attachmentsAsync.when(
          loading: () => const SizedBox(height: 4),
          error: (_, _) => const SizedBox.shrink(),
          data: (attachments) {
            if (attachments.isEmpty) {
              return Text('No attachments yet.', style: Theme.of(context).textTheme.bodySmall);
            }
            return Card(
              child: Column(
                children: [
                  for (final attachment in attachments)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          attachment.typeBadge,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                      title: Text(attachment.fileName, overflow: TextOverflow.ellipsis),
                      subtitle: Text(attachment.sizeLabel),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        tooltip: 'Delete attachment',
                        onPressed: () => _delete(attachment.id),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _uploading ? null : _showAddSheet,
          icon: _uploading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.add, size: 18),
          label: Text(_uploading ? 'Uploading…' : 'Add Attachment'),
        ),
      ],
    );
  }
}

class _ActivitySection extends ConsumerWidget {
  const _ActivitySection({required this.leadId});

  final String leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(leadActivityProvider(leadId));
    return activityAsync.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
      error: (_, _) => const SizedBox.shrink(),
      data: (page) {
        if (page.content.isEmpty) {
          return Text('No activity yet.', style: Theme.of(context).textTheme.bodySmall);
        }
        return Column(
          children: [
            for (final entry in page.content)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.description),
                          Text(entry.createdAt, style: Theme.of(context).textTheme.bodySmall),
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
