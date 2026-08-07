import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/paged.dart';
import 'activity_models.dart';

class ActivityRepository {
  ActivityRepository(this._dio);

  final Dio _dio;

  Future<Paged<ActivityResponse>> list({String? leadId, String? ownerId, String? type, int size = 30}) async {
    try {
      final response = await _dio.get(
        '/activity',
        queryParameters: {
          if (leadId != null) 'leadId': leadId,
          if (ownerId != null) 'ownerId': ownerId,
          if (type != null) 'type': type,
          'size': size,
        },
      );
      return Paged.fromJson(response.data as Map<String, dynamic>, ActivityResponse.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
