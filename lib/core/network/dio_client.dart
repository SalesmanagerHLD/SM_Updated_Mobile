import 'package:dio/dio.dart';

import '../config/env.dart';
import '../storage/secure_token_store.dart';
import 'auth_interceptor.dart';

const _connectTimeout = Duration(seconds: 15);
const _receiveTimeout = Duration(seconds: 20);

BaseOptions _baseOptions() => BaseOptions(
  baseUrl: Env.apiBaseUrl,
  connectTimeout: _connectTimeout,
  receiveTimeout: _receiveTimeout,
  headers: {'Content-Type': 'application/json'},
);

/// A bare Dio instance with no interceptors — used for `/auth/*` endpoints
/// (login, refresh, logout) and as [AuthInterceptor]'s own refresh client,
/// so those calls never recurse into 401-handling for themselves. Mirrors
/// the web app's separate bare `axios.post` call for `/auth/refresh` instead
/// of its shared, interceptor-attached `axiosInstance`.
Dio buildPlainDio() => Dio(_baseOptions());

/// The authenticated client every feature repository should use — attaches
/// `Authorization: Bearer <token>`, and on a 401 shares one in-flight
/// refresh across concurrent requests before retrying each exactly once.
Dio buildAuthenticatedDio({
  required SecureTokenStore tokenStore,
  required Dio refreshDio,
  required Future<void> Function() onUnauthenticated,
}) {
  final dio = Dio(_baseOptions());
  dio.interceptors.add(
    AuthInterceptor(
      tokenStore: tokenStore,
      refreshDio: refreshDio,
      onUnauthenticated: onUnauthenticated,
    ),
  );
  return dio;
}
