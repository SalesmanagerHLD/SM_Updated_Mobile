import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Mirrors `frontend/src/api/authStorage.ts`'s `AuthState` shape exactly
/// (`accessToken, refreshToken, employeeId, orgId, role`), stored as one
/// JSON blob under one key — just ported to Keychain/Keystore-backed
/// secure storage instead of localStorage.
class AuthState {
  const AuthState({
    required this.accessToken,
    required this.refreshToken,
    required this.employeeId,
    required this.orgId,
    required this.role,
  });

  final String accessToken;
  final String refreshToken;
  final String employeeId;
  final String orgId;
  final String role; // "ADMIN" | "EMPLOYEE"

  bool get isAdmin => role == 'ADMIN';

  factory AuthState.fromJson(Map<String, dynamic> json) => AuthState(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    employeeId: json['employeeId'] as String,
    orgId: json['orgId'] as String,
    role: json['role'] as String,
  );

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'employeeId': employeeId,
    'orgId': orgId,
    'role': role,
  };

  AuthState copyWithTokens({required String accessToken, required String refreshToken}) =>
      AuthState(
        accessToken: accessToken,
        refreshToken: refreshToken,
        employeeId: employeeId,
        orgId: orgId,
        role: role,
      );
}

/// Persistence backing store only — read once at app boot, written whenever
/// auth state changes. Unlike the web's `authStorage.ts`, no pub-sub is
/// needed here: `AuthNotifier` (features/auth/application/auth_providers.dart)
/// is itself the single in-memory source of truth that widgets watch via
/// Riverpod; this class never needs to notify anything on its own.
class SecureTokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'salesmanager.auth';

  final FlutterSecureStorage _storage;

  Future<AuthState?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      return AuthState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Corrupt/unparseable stored value - treat as logged out rather than crash.
      await clear();
      return null;
    }
  }

  Future<void> write(AuthState state) async {
    await _storage.write(key: _key, value: jsonEncode(state.toJson()));
  }

  Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}
