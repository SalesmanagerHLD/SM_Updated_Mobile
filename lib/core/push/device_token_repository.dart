import 'package:dio/dio.dart';

import '../network/api_exception.dart';

abstract class DevicePlatform {
  static const android = 'ANDROID';
  static const ios = 'IOS';
}

/// `POST /device-tokens` already accepts `ANDROID`/`IOS` platform values
/// server-side (confirmed against `DeviceTokenController`/`DevicePlatform`)
/// — no backend changes needed for a native client to register.
class DeviceTokenRepository {
  DeviceTokenRepository(this._dio);

  final Dio _dio;

  Future<void> register({required String token, required String platform}) async {
    try {
      await _dio.post('/device-tokens', data: {'token': token, 'platform': platform});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Best-effort — never throws. Matches the backend's own "no-op if not
  /// found/not yours" contract, so this is safe to fire without awaiting
  /// completion on logout.
  Future<void> unregister(String token) async {
    try {
      await _dio.delete('/device-tokens/$token');
    } catch (_) {
      // Ignore.
    }
  }
}
