import 'package:dio/dio.dart';

import 'theme_models.dart';

/// Org-wide branding + personal override, straight ports of the web app's
/// `frontend/src/api/themeApi.ts` calls onto the same two endpoints.
class ThemeRepository {
  ThemeRepository(this._dio);

  final Dio _dio;

  /// Always fully non-null on the wire - the backend never returns a
  /// partial org theme.
  Future<EffectiveThemeSettings> getOrganizationTheme() async {
    final response = await _dio.get('/organizations/me/theme');
    return EffectiveThemeSettings.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ThemePreference> getThemePreference() async {
    final response = await _dio.get('/employees/me/theme-preference');
    return ThemePreference.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> updateThemePreference(ThemePreference preference) async {
    await _dio.put('/employees/me/theme-preference', data: preference.toJson());
  }
}
