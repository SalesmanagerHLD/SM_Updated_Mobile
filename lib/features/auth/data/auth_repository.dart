import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_token_store.dart';

/// Talks to `/auth/*` only — no self-registration here (`register-organization`
/// is a web/admin-only flow; the mockup's Sign In screen is explicit that
/// "Accounts are provisioned by your organization's admin").
class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<AuthState> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthState.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Best-effort — the caller always clears local state regardless of
  /// whether this succeeds, matching the web app's `logout()` behavior.
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (_) {
      // Ignore - local session clearing is what actually matters.
    }
  }
}
