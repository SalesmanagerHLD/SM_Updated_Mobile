import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/leave_providers.dart';
import '../data/leave_models.dart';

class RequestLeaveScreen extends ConsumerStatefulWidget {
  const RequestLeaveScreen({super.key});

  @override
  ConsumerState<RequestLeaveScreen> createState() => _RequestLeaveScreenState();
}

class _RequestLeaveScreenState extends ConsumerState<RequestLeaveScreen> {
  String? _leaveTypeId;
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    if (_leaveTypeId == null || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pick a leave type and date range')));
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(leaveRepositoryProvider)
          .createQueued(
            LeaveRequestCreateRequest(
              leaveTypeId: _leaveTypeId!,
              startDate: _isoDate(_startDate!),
              endDate: _isoDate(_endDate!),
              reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
            ),
          );
      ref.invalidate(myLeaveRequestsProvider);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaveTypesAsync = ref.watch(leaveTypesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Request Leave')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          leaveTypesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Text('Could not load leave types.'),
            data: (types) => DropdownButtonFormField<String>(
              initialValue: _leaveTypeId,
              decoration: const InputDecoration(labelText: 'Leave Type'),
              isExpanded: true,
              items: [for (final t in types) DropdownMenuItem(value: t.id, child: Text(t.name))],
              onChanged: (v) => setState(() => _leaveTypeId = v),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Start Date'),
                    child: Text(_startDate == null ? '—' : _isoDate(_startDate!)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? _startDate ?? DateTime.now(),
                      firstDate: _startDate ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _endDate = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'End Date'),
                    child: Text(_endDate == null ? '—' : _isoDate(_endDate!)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _reasonController,
            decoration: const InputDecoration(labelText: 'Reason (optional)'),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                : const Text('Submit Request'),
          ),
        ],
      ),
    );
  }
}
