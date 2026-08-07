import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../leads/application/lead_providers.dart';
import '../../masters/application/master_data_providers.dart';
import '../../masters/data/master_data_models.dart';
import '../application/visit_providers.dart';
import '../data/visit_models.dart';

/// Log Visit — pre-filled from the parent Lead's current contact/
/// qualification fields (per the web app's convention: the Visit only adds
/// what's new about THIS interaction, the Lead stays the source of truth
/// for contact data). Create-only for v1 (no edit mode wired up yet — the
/// only entry point today is Lead Detail's "Log Visit" button).
class VisitFormScreen extends ConsumerStatefulWidget {
  const VisitFormScreen({super.key, required this.leadId});

  final String leadId;

  @override
  ConsumerState<VisitFormScreen> createState() => _VisitFormScreenState();
}

class _VisitFormScreenState extends ConsumerState<VisitFormScreen> {
  String _visitType = VisitType.field;
  DateTime _visitDate = DateTime.now();
  TimeOfDay? _scheduledTime;
  String? _purposeId;
  String? _interestLevelId;
  bool _decisionMaker = false;
  DateTime? _nextVisitDate;
  bool _logAsCompleted = false;
  bool _submitting = false;
  bool _prefilled = false;

  final _remarksController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactNoController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _budgetController = TextEditingController();
  String? _cityId;
  String? _stateId;
  String? _designationId;

  @override
  void dispose() {
    _remarksController.dispose();
    _contactPersonController.dispose();
    _contactNoController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _prefillFromLead() {
    final lead = ref.read(leadDetailProvider(widget.leadId)).valueOrNull;
    if (lead == null || _prefilled) return;
    _prefilled = true;
    _contactPersonController.text = lead.contactPerson;
    _contactNoController.text = lead.contactNo;
    _emailController.text = lead.email ?? '';
    _addressController.text = lead.address ?? '';
    _budgetController.text = lead.budgetRange ?? '';
    _cityId = lead.cityId;
    _stateId = lead.stateId;
    _designationId = lead.designationId;
    _interestLevelId = lead.interestLevelId;
    _decisionMaker = lead.decisionMakerIdentified;
  }

  String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final request = VisitCreateRequest(
        leadId: widget.leadId,
        visitDate: _isoDate(_visitDate),
        visitType: _visitType,
        scheduledTime: _scheduledTime == null
            ? null
            : '${_scheduledTime!.hour.toString().padLeft(2, '0')}:${_scheduledTime!.minute.toString().padLeft(2, '0')}:00',
        purposeId: _purposeId,
        interestLevelId: _interestLevelId,
        contactPerson: _contactPersonController.text.trim().isEmpty
            ? null
            : _contactPersonController.text.trim(),
        designationId: _designationId,
        contactNo: _contactNoController.text.trim().isEmpty ? null : _contactNoController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        stateId: _stateId,
        cityId: _cityId,
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        budgetRange: _budgetController.text.trim().isEmpty ? null : _budgetController.text.trim(),
        decisionMakerIdentified: _decisionMaker,
        remarks: _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim(),
        nextVisitDate: _nextVisitDate == null ? null : _isoDate(_nextVisitDate!),
        status: _logAsCompleted ? VisitStatus.completed : null,
      );
      await ref.read(visitRepositoryProvider).createQueued(request);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _prefillFromLead();
    final purposes = ref.watch(masterDataProvider(MasterType.visitPurpose)).valueOrNull ?? const [];
    final interestLevels = ref.watch(masterDataProvider(MasterType.interestLevel)).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
        leadingWidth: 80,
        title: const Text('Log Visit'),
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: VisitType.field, label: Text('Field')),
              ButtonSegment(value: VisitType.telephonic, label: Text('Telephonic')),
            ],
            selected: {_visitType},
            onSelectionChanged: (s) => setState(() => _visitType = s.first),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _visitDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _visitDate = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Visit Date'),
                    child: Text(_isoDate(_visitDate)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _scheduledTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) setState(() => _scheduledTime = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Scheduled Time'),
                    child: Text(_scheduledTime?.format(context) ?? '—'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _purposeId,
            decoration: const InputDecoration(labelText: 'Purpose'),
            isExpanded: true,
            items: [
              const DropdownMenuItem(value: null, child: Text('—')),
              for (final p in purposes) DropdownMenuItem(value: p.id, child: Text(p.label)),
            ],
            onChanged: (v) => setState(() => _purposeId = v),
          ),
          const SizedBox(height: 4),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('This visit already happened (log as completed)'),
            value: _logAsCompleted,
            onChanged: (v) => setState(() => _logAsCompleted = v ?? false),
          ),
          const Divider(height: 32),
          Text('Required details', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextFormField(
            controller: _contactPersonController,
            decoration: const InputDecoration(labelText: 'Contact Person'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contactNoController,
            decoration: const InputDecoration(labelText: 'Contact Number'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          Text('Interest Level', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              for (final level in interestLevels)
                ChoiceChip(
                  label: Text(level.label),
                  selected: _interestLevelId == level.id,
                  onSelected: (_) => setState(() => _interestLevelId = level.id),
                ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _nextVisitDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _nextVisitDate = picked);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Next Visit Date'),
              child: Text(_nextVisitDate == null ? '—' : _isoDate(_nextVisitDate!)),
            ),
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Decision Maker present'),
            value: _decisionMaker,
            onChanged: (v) => setState(() => _decisionMaker = v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _remarksController,
            decoration: const InputDecoration(labelText: 'Remarks'),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          Text('Additional details', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _budgetController,
            decoration: const InputDecoration(labelText: 'Budget Range'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address'),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
