import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../masters/application/master_data_providers.dart';
import '../../masters/data/master_data_models.dart';
import '../../visits/data/visit_models.dart';
import '../application/lead_providers.dart';
import '../data/lead_models.dart';

/// New Lead — 2-step wizard matching the mockup exactly: Step 1 is the
/// same fast/minimal field set as the web app's original two-step
/// progressive capture (Company, Contact Person, Contact No, City, Lead
/// Source, Industry + "log as today's visit"), Step 2 holds everything
/// else. Deliberately picked over the web's later single-page "Required
/// Details" grid (Section 23 of the implementation doc) — that reordering
/// was designed for a wide desktop form; a 2-step wizard is the better fit
/// for a phone screen, and it's what the mockup itself shows.
///
/// v1 scope note: master-data fields here are pick-only (a plain dropdown
/// against existing org master data) — the web app's "pick or type"
/// creatable-autocomplete UX for these fields is not reproduced yet.
class LeadFormScreen extends ConsumerStatefulWidget {
  const LeadFormScreen({super.key});

  @override
  ConsumerState<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends ConsumerState<LeadFormScreen> {
  int _step = 0;
  final _step1Key = GlobalKey<FormState>();

  final _companyNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactNoController = TextEditingController();
  final _remarksController = TextEditingController();
  final _turnoverController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _currentSolutionController = TextEditingController();
  final _budgetController = TextEditingController();

  String? _cityId;
  String? _leadSourceId;
  String? _industryId;
  String? _businessTypeId;
  String? _designationId;
  String? _stateId;
  String? _interestLevelId;
  final Set<String> _productIds = {};
  bool _decisionMaker = false;
  DateTime? _nextFollowupDate;
  DateTime? _expectedCloseDate;
  bool _logAsVisitToday = true;
  String _visitType = VisitType.field;

  bool _submitting = false;
  List<LeadDuplicateMatch> _duplicates = const [];

  @override
  void dispose() {
    _companyNameController.dispose();
    _contactPersonController.dispose();
    _contactNoController.dispose();
    _remarksController.dispose();
    _turnoverController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _currentSolutionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _checkDuplicates() async {
    if (_companyNameController.text.trim().isEmpty && _contactNoController.text.trim().isEmpty) {
      return;
    }
    final matches = await ref
        .read(leadRepositoryProvider)
        .checkDuplicates(
          contactNo: _contactNoController.text.trim(),
          companyName: _companyNameController.text.trim(),
        );
    if (mounted) setState(() => _duplicates = matches);
  }

  void _goToStep2() {
    if (_step1Key.currentState?.validate() != true) return;
    setState(() => _step = 1);
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final request = LeadCreateRequest(
        companyName: _companyNameController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        contactNo: _contactNoController.text.trim(),
        cityId: _cityId,
        leadSourceId: _leadSourceId,
        industryId: _industryId,
        businessTypeId: _businessTypeId,
        designationId: _designationId,
        stateId: _stateId,
        interestLevelId: _interestLevelId,
        productIds: _productIds.toList(),
        decisionMakerIdentified: _decisionMaker,
        nextFollowupDate: _formatDate(_nextFollowupDate),
        expectedCloseDate: _formatDate(_expectedCloseDate),
        remarks: _emptyToNull(_remarksController.text),
        turnover: num.tryParse(_turnoverController.text),
        email: _emptyToNull(_emailController.text),
        address: _emptyToNull(_addressController.text),
        currentProductSolution: _emptyToNull(_currentSolutionController.text),
        budgetRange: _emptyToNull(_budgetController.text),
        logAsVisitToday: _logAsVisitToday,
        visitType: _logAsVisitToday ? _visitType : null,
      );
      final leadId = await ref.read(leadRepositoryProvider).createQueued(request);
      if (mounted) context.go('/leads/$leadId');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _emptyToNull(String value) => value.trim().isEmpty ? null : value.trim();

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Lead')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                _StepIndicator(index: 0, label: 'Required Details', active: _step == 0),
                Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                _StepIndicator(index: 1, label: 'Details', active: _step == 1),
              ],
            ),
          ),
          Expanded(
            child: _step == 0 ? _buildStep1(context) : _buildStep2(context),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton(
                onPressed: _submitting ? null : (_step == 0 ? _goToStep2 : _submit),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text(_step == 0 ? 'Next' : 'Save Lead'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(BuildContext context) {
    final cities = ref.watch(masterDataProvider(MasterType.city)).valueOrNull ?? const [];
    final leadSources = ref.watch(masterDataProvider(MasterType.leadSource)).valueOrNull ?? const [];
    final industries = ref.watch(masterDataProvider(MasterType.industry)).valueOrNull ?? const [];

    return Form(
      key: _step1Key,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_duplicates.isNotEmpty)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Possible duplicate',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    for (final match in _duplicates)
                      Text(
                        '${match.companyName} · ${match.contactPerson}',
                        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                      ),
                  ],
                ),
              ),
            ),
          TextFormField(
            controller: _companyNameController,
            decoration: const InputDecoration(labelText: 'Company Name'),
            textInputAction: TextInputAction.next,
            onEditingComplete: _checkDuplicates,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contactPersonController,
            decoration: const InputDecoration(labelText: 'Contact Person'),
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contactNoController,
            decoration: const InputDecoration(labelText: 'Contact Number'),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onEditingComplete: _checkDuplicates,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) return 'Enter a 10-digit number';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _MasterDropdown(
            label: 'City',
            items: cities,
            value: _cityId,
            onChanged: (v) => setState(() => _cityId = v),
          ),
          const SizedBox(height: 12),
          _MasterDropdown(
            label: 'Lead Source',
            items: leadSources,
            value: _leadSourceId,
            onChanged: (v) => setState(() => _leadSourceId = v),
          ),
          const SizedBox(height: 12),
          _MasterDropdown(
            label: 'Industry',
            items: industries,
            value: _industryId,
            onChanged: (v) => setState(() => _industryId = v),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Log this as today's visit"),
            value: _logAsVisitToday,
            onChanged: (v) => setState(() => _logAsVisitToday = v),
          ),
          if (_logAsVisitToday)
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: VisitType.field, label: Text('Field')),
                ButtonSegment(value: VisitType.telephonic, label: Text('Telephonic')),
              ],
              selected: {_visitType},
              onSelectionChanged: (s) => setState(() => _visitType = s.first),
            ),
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context) {
    final businessTypes = ref.watch(masterDataProvider(MasterType.businessType)).valueOrNull ?? const [];
    final designations = ref.watch(masterDataProvider(MasterType.designation)).valueOrNull ?? const [];
    final states = ref.watch(masterDataProvider(MasterType.state)).valueOrNull ?? const [];
    final products = ref.watch(masterDataProvider(MasterType.product)).valueOrNull ?? const [];
    final interestLevels = ref.watch(masterDataProvider(MasterType.interestLevel)).valueOrNull ?? const [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MasterDropdown(
          label: 'Business Type',
          items: businessTypes,
          value: _businessTypeId,
          onChanged: (v) => setState(() => _businessTypeId = v),
        ),
        const SizedBox(height: 12),
        _MasterDropdown(
          label: 'Designation',
          items: designations,
          value: _designationId,
          onChanged: (v) => setState(() => _designationId = v),
        ),
        const SizedBox(height: 12),
        _MasterDropdown(
          label: 'State',
          items: states,
          value: _stateId,
          onChanged: (v) => setState(() => _stateId = v),
        ),
        const SizedBox(height: 12),
        _MultiSelectField(
          label: 'Products',
          items: products,
          selectedIds: _productIds,
          onChanged: (ids) => setState(() {
            _productIds
              ..clear()
              ..addAll(ids);
          }),
        ),
        const SizedBox(height: 12),
        _MasterDropdown(
          label: 'Interest Level',
          items: interestLevels,
          value: _interestLevelId,
          onChanged: (v) => setState(() => _interestLevelId = v),
        ),
        const SizedBox(height: 4),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Decision Maker identified'),
          value: _decisionMaker,
          onChanged: (v) => setState(() => _decisionMaker = v ?? false),
        ),
        const SizedBox(height: 8),
        _DateField(
          label: 'Next Follow-up Date',
          value: _nextFollowupDate,
          onChanged: (d) => setState(() => _nextFollowupDate = d),
        ),
        const SizedBox(height: 12),
        _DateField(
          label: 'Expected Closure Date',
          value: _expectedCloseDate,
          onChanged: (d) => setState(() => _expectedCloseDate = d),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _remarksController,
          decoration: const InputDecoration(labelText: 'Remarks'),
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        Text('Additional', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: _turnoverController,
          decoration: const InputDecoration(labelText: 'Turnover'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(labelText: 'Address'),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _currentSolutionController,
          decoration: const InputDecoration(labelText: 'Current Product/Solution'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _budgetController,
          decoration: const InputDecoration(labelText: 'Budget Range'),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.index, required this.label, required this.active});

  final int index;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: active ? scheme.primary : scheme.surfaceContainerHighest,
          child: Text(
            '${index + 1}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: active ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: active ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _MasterDropdown extends StatelessWidget {
  const _MasterDropdown({
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<MasterDataItem> items;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      isExpanded: true,
      items: [
        const DropdownMenuItem(value: null, child: Text('—')),
        for (final item in items) DropdownMenuItem(value: item.id, child: Text(item.label)),
      ],
      onChanged: onChanged,
    );
  }
}

class _MultiSelectField extends StatelessWidget {
  const _MultiSelectField({
    required this.label,
    required this.items,
    required this.selectedIds,
    required this.onChanged,
  });

  final String label;
  final List<MasterDataItem> items;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final labelText = items
        .where((i) => selectedIds.contains(i.id))
        .map((i) => i.label)
        .join(', ');
    return InkWell(
      onTap: () async {
        final result = await showModalBottomSheet<Set<String>>(
          context: context,
          builder: (context) => _MultiSelectSheet(items: items, initiallySelected: selectedIds),
        );
        if (result != null) onChanged(result);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(labelText.isEmpty ? '—' : labelText, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _MultiSelectSheet extends StatefulWidget {
  const _MultiSelectSheet({required this.items, required this.initiallySelected});

  final List<MasterDataItem> items;
  final Set<String> initiallySelected;

  @override
  State<_MultiSelectSheet> createState() => _MultiSelectSheetState();
}

class _MultiSelectSheetState extends State<_MultiSelectSheet> {
  late final Set<String> _selected = {...widget.initiallySelected};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView(
              children: [
                for (final item in widget.items)
                  CheckboxListTile(
                    title: Text(item.label),
                    value: _selected.contains(item.id),
                    onChanged: (checked) => setState(() {
                      if (checked == true) {
                        _selected.add(item.id);
                      } else {
                        _selected.remove(item.id);
                      }
                    }),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(_selected),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value, required this.onChanged});

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, suffixIcon: const Icon(Icons.calendar_today, size: 18)),
        child: Text(
          value == null
              ? '—'
              : '${value!.year.toString().padLeft(4, '0')}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }
}
