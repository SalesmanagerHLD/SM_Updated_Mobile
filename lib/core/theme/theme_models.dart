import 'package:flutter/material.dart';

enum AppDensity {
  comfortable,
  compact;

  static AppDensity fromWire(String? value) =>
      value == 'compact' ? AppDensity.compact : AppDensity.comfortable;
}

enum AppUiStyle {
  standard,
  minimalist;

  static AppUiStyle fromWire(String? value) =>
      value == 'minimalist' ? AppUiStyle.minimalist : AppUiStyle.standard;
}

/// Fully-resolved theme, ready for `AppThemeBuilder` — mirrors
/// `frontend/src/theme/createAppTheme.ts`'s `EffectiveThemeSettings` (same 4
/// dimensions: primaryColor/mode/density/uiStyle), merged upstream from org
/// branding + personal override + hardcoded fallback by `ThemeNotifier`.
class EffectiveThemeSettings {
  const EffectiveThemeSettings({
    required this.primaryColor,
    required this.mode,
    required this.density,
    required this.uiStyle,
  });

  final Color primaryColor;
  final Brightness mode;
  final AppDensity density;
  final AppUiStyle uiStyle;

  /// The mockup's own default swatch (`#3547E0`, indigo) and its light-mode
  /// rendering (the mockup's screens are light throughout except the Sign In
  /// splash, which is a deliberate branding choice, not the app's base
  /// mode) — deliberately not the web's dark-mode-era `#6366f1` default;
  /// the two are independently configurable per-org values, not required to
  /// match. See the mobile app plan's Design Reference section.
  static const EffectiveThemeSettings hardcodedDefault = EffectiveThemeSettings(
    primaryColor: Color(0xFF3547E0),
    mode: Brightness.light,
    density: AppDensity.comfortable,
    uiStyle: AppUiStyle.standard,
  );

  Map<String, dynamic> toJson() => {
    'primaryColor':
        '#${primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
    'mode': mode == Brightness.dark ? 'dark' : 'light',
    'density': density.name,
    'uiStyle': uiStyle.name,
  };

  factory EffectiveThemeSettings.fromJson(Map<String, dynamic> json) => EffectiveThemeSettings(
    primaryColor: parseColor(json['primaryColor'] as String?) ?? hardcodedDefault.primaryColor,
    mode: json['mode'] == 'dark' ? Brightness.dark : Brightness.light,
    density: AppDensity.fromWire(json['density'] as String?),
    uiStyle: AppUiStyle.fromWire(json['uiStyle'] as String?),
  );

  /// Public so `ThemeNotifier` can reuse it when merging a [ThemePreference]
  /// (whose `primaryColor` is a separate nullable string) on top of an org
  /// default.
  static Color? parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    var value = hex.replaceFirst('#', '');
    if (value.length == 6) value = 'FF$value';
    final parsed = int.tryParse(value, radix: 16);
    return parsed == null ? null : Color(parsed);
  }
}

/// Per-field-nullable personal override, straight from
/// `GET /employees/me/theme-preference` — `null` on any field means
/// "inherit the org value for this field," same semantics as the web app.
class ThemePreference {
  const ThemePreference({this.primaryColor, this.mode, this.density, this.uiStyle});

  final String? primaryColor;
  final String? mode;
  final String? density;
  final String? uiStyle;

  factory ThemePreference.fromJson(Map<String, dynamic> json) => ThemePreference(
    primaryColor: json['primaryColor'] as String?,
    mode: json['mode'] as String?,
    density: json['density'] as String?,
    uiStyle: json['uiStyle'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'primaryColor': primaryColor,
    'mode': mode,
    'density': density,
    'uiStyle': uiStyle,
  };

  static const empty = ThemePreference();
}
