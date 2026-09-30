import 'dart:convert';
import 'dart:ui' show Brightness;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/network_providers.dart';
import '../../features/auth/application/auth_providers.dart';
import 'theme_models.dart';
import 'theme_repository.dart';

final themeRepositoryProvider = Provider<ThemeRepository>(
  (ref) => ThemeRepository(ref.watch(dioProvider)),
);

String _cacheKey(String orgId) => 'salesmanager.theme.$orgId';

/// Resolves the effective theme with the same 3-tier precedence as
/// `frontend/src/theme/ThemeContext.tsx`'s `resolveEffectiveTheme`:
/// personal preference ?? org default ?? hardcoded fallback, applied
/// per-field independently. Caches the resolved result (keyed by orgId) so
/// a warm start paints instantly instead of flashing the hardcoded default
/// while the network calls are in flight - same purpose as the web app's
/// `localStorage`-keyed theme cache.
class ThemeNotifier extends AsyncNotifier<EffectiveThemeSettings> {
  @override
  Future<EffectiveThemeSettings> build() async {
    final auth = ref.watch(authNotifierProvider).valueOrNull;
    if (auth == null) {
      return EffectiveThemeSettings.hardcodedDefault;
    }

    final prefs = await SharedPreferences.getInstance();
    final cached = _readCache(prefs, auth.orgId);

    final repository = ref.read(themeRepositoryProvider);
    try {
      final org = await repository.getOrganizationTheme();
      final preference = await repository.getThemePreference();
      final merged = _merge(preference, org);
      await prefs.setString(_cacheKey(auth.orgId), jsonEncode(merged.toJson()));
      return merged;
    } catch (_) {
      // Offline or the calls failed for some other reason - serve whatever
      // was last resolved for this org rather than falling all the way
      // back to the hardcoded default.
      return cached ?? EffectiveThemeSettings.hardcodedDefault;
    }
  }

  EffectiveThemeSettings? _readCache(SharedPreferences prefs, String orgId) {
    final raw = prefs.getString(_cacheKey(orgId));
    if (raw == null) return null;
    try {
      return EffectiveThemeSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  EffectiveThemeSettings _merge(ThemePreference preference, EffectiveThemeSettings org) =>
      EffectiveThemeSettings(
        primaryColor: EffectiveThemeSettings.parseColor(preference.primaryColor) ?? org.primaryColor,
        mode: switch (preference.mode) {
          'dark' => Brightness.dark,
          'light' => Brightness.light,
          _ => org.mode,
        },
        density: preference.density != null
            ? AppDensity.fromWire(preference.density)
            : org.density,
        uiStyle: preference.uiStyle != null ? AppUiStyle.fromWire(preference.uiStyle) : org.uiStyle,
      );

  /// Persists a personal override and refetches - used by the Settings
  /// screen's UI Style / Primary Color controls (later phase).
  Future<void> updatePreference(ThemePreference preference) async {
    final repository = ref.read(themeRepositoryProvider);
    await repository.updateThemePreference(preference);
    ref.invalidateSelf();
    await future;
  }
}

final themeNotifierProvider = AsyncNotifierProvider<ThemeNotifier, EffectiveThemeSettings>(
  ThemeNotifier.new,
);
