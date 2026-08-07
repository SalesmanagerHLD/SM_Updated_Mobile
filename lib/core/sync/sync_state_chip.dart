import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sync_providers.dart';

/// Per-record sync indicator (list rows + detail header) — amber
/// "Syncing…" while a create/update is queued, red "Needs attention" once
/// a real conflict/failure surfaces, nothing once synced. Deliberately
/// distinct from [SyncStatusBanner], which is the app-wide pending-changes
/// summary, not a per-record indicator.
class LeadSyncStateChip extends ConsumerWidget {
  const LeadSyncStateChip({super.key, required this.leadId});

  final String leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leadSyncStateProvider(leadId)).valueOrNull;
    return _chip(context, state);
  }
}

class VisitSyncStateChip extends ConsumerWidget {
  const VisitSyncStateChip({super.key, required this.visitId});

  final String visitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(visitSyncStateProvider(visitId)).valueOrNull;
    return _chip(context, state);
  }
}

Widget _chip(BuildContext context, String? state) {
  return switch (state) {
    'pendingCreate' || 'pendingUpdate' => const _Pill(label: 'Syncing…', color: Color(0xFFB54708)),
    'conflict' => const _Pill(label: 'Needs attention', color: Color(0xFFB42318)),
    _ => const SizedBox.shrink(),
  };
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(100)),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}
