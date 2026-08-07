import 'package:dio/dio.dart';

import '../storage/secure_token_store.dart';

/// Ports `frontend/src/api/axiosInstance.ts`'s refresh flow exactly:
/// - attach `Authorization: Bearer <accessToken>` on every request
/// - on a 401, share ONE in-flight refresh call across every concurrent
///   401 (via [_refreshFuture]) rather than firing a refresh per request
/// - retry the original request exactly once after a successful refresh
/// - on refresh failure (or a request that's already been retried once),
///   clear stored tokens and call [onUnauthenticated] so the app can boot
///   the user back to /login
///
/// [refreshDio] must be a bare Dio instance with NO interceptors attached
/// (no Authorization header, no retry logic) — using the intercepted client
/// for the refresh call itself would recurse into this same 401 handling,
/// exactly the reason the web app uses a separate bare `axios.post` for
/// `/auth/refresh` instead of its shared `axiosInstance`.
class AuthInterceptor extends Interceptor {
  // ignore: prefer_initializing_formals
  AuthInterceptor({
    required SecureTokenStore tokenStore,
    required Dio refreshDio,
    required Future<void> Function() onUnauthenticated,
  }) : _tokenStore = tokenStore,
       _refreshDio = refreshDio,
       _onUnauthenticated = onUnauthenticated;

  // Named-parameter constructor above intentionally doesn't use
  // initializing formals (`this._tokenStore`) — the public parameter names
  // (`tokenStore`, `refreshDio`, `onUnauthenticated`) read better at call
  // sites than the underscored field names would.
  final SecureTokenStore _tokenStore;
  final Dio _refreshDio;
  final Future<void> Function() _onUnauthenticated;

  Future<String?>? _refreshFuture;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final auth = await _tokenStore.read();
    if (auth != null) {
      options.headers['Authorization'] = 'Bearer ${auth.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final request = err.requestOptions;
    final alreadyRetried = request.extra['retried'] == true;
    if (alreadyRetried) {
      await _forceLogout();
      return handler.next(err);
    }

    final auth = await _tokenStore.read();
    if (auth == null) {
      await _forceLogout();
      return handler.next(err);
    }

    final newAccessToken = await _performRefresh(auth.refreshToken);
    if (newAccessToken == null) {
      await _forceLogout();
      return handler.next(err);
    }

    request.extra['retried'] = true;
    request.headers['Authorization'] = 'Bearer $newAccessToken';
    try {
      final response = await _refreshDio.fetch(request);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<String?> _performRefresh(String refreshToken) {
    // A shared Future means concurrent 401s (e.g. several list calls firing
    // together on a screen) trigger exactly one network call, matching
    // axiosInstance.ts's module-level `refreshPromise` guard.
    return _refreshFuture ??= _doRefresh(refreshToken).whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<String?> _doRefresh(String refreshToken) async {
    try {
      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final newAuth = AuthState.fromJson(response.data as Map<String, dynamic>);
      await _tokenStore.write(newAuth);
      return newAuth.accessToken;
    } catch (_) {
      return null;
    }
  }

  Future<void> _forceLogout() async {
    await _tokenStore.clear();
    await _onUnauthenticated();
  }
}
