import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sync_providers.dart';

/// A slim bar shown app-wide whenever there are unsynced local changes —
/// always accurate even before an automatic trigger (connectivity restore,
/// app foreground) has fired, since it's driven directly by the outbox
/// table via reactive Drift streams, not by whatever the last sync attempt
/// happened to report.
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingOutboxCountProvider).valueOrNull ?? 0;
    final hasFailed = ref.watch(hasFailedOutboxProvider).valueOrNull ?? false;

    if (pendingCount == 0 && !hasFailed) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final isError = hasFailed;

    return Material(
      color: isError ? scheme.errorContainer : scheme.primaryContainer,
      child: InkWell(
        onTap: () => ref.read(syncCoordinatorProvider.notifier).syncNow(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.sync,
                size: 16,
                color: isError ? scheme.onErrorContainer : scheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isError
                      ? 'Some changes need attention'
                      : '$pendingCount change${pendingCount == 1 ? '' : 's'} waiting to sync',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isError ? scheme.onErrorContainer : scheme.onPrimaryContainer,
                  ),
                ),
              ),
              Text(
                'Sync now',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isError ? scheme.onErrorContainer : scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
