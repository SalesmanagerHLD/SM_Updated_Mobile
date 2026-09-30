import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../core/theme/theme_models.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../../entitlements/application/entitlement_providers.dart';
import '../../entitlements/data/entitlement_repository.dart';

/// Settings / Profile tab. Read-only profile + theme snapshot and a working
/// Log Out for this phase; the "Organization Branding" editing controls
/// (UI Style toggle, Primary Color swatches, per mockup screen 10) and the
/// Team & Permissions / Leave Types & Holidays / Data Export nav rows land
/// once their target screens exist.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider).valueOrNull;
    final theme = ref.watch(themeNotifierProvider).valueOrNull;

    // Display-only, exactly like the web app's `jwt-decode` usage in
    // AuthContext.tsx - never trust this for access-control decisions, the
    // backend remains the sole authority.
    String? email;
    if (auth != null) {
      try {
        final claims = JwtDecoder.decode(auth.accessToken);
        email = claims['email'] as String?;
      } catch (_) {
        email = null;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (auth != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        _initials(email),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            email ?? auth.employeeId,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(auth.role, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (theme != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Appearance', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 10),
                    _ThemeRow(label: 'Mode', value: theme.mode == Brightness.dark ? 'Dark' : 'Light'),
                    _ThemeRow(
                      label: 'Density',
                      value: theme.density == AppDensity.compact ? 'Compact' : 'Comfortable',
                    ),
                    _ThemeRow(
                      label: 'UI style',
                      value: theme.uiStyle == AppUiStyle.minimalist ? 'Minimalist' : 'Standard',
                    ),
                    Row(
                      children: [
                        const Text('Primary color'),
                        const Spacer(),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (ref.watch(hasEntitlementProvider(FeatureEntitlement.teamVisibility))) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Team & Permissions'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/team'),
              ),
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  String _initials(String? email) {
    if (email == null || email.isEmpty) return '?';
    final namePart = email.split('@').first;
    return namePart.isNotEmpty ? namePart[0].toUpperCase() : '?';
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
