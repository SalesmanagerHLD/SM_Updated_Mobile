import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import 'master_data_models.dart';

class MasterDataRepository {
  MasterDataRepository(this._dio);

  final Dio _dio;

  Future<List<MasterDataItem>> list(String type, {bool includeInactive = false}) async {
    try {
      final response = await _dio.get(
        '/masters/$type',
        queryParameters: {'includeInactive': includeInactive},
      );
      return (response.data as List<dynamic>)
          .map((e) => MasterDataItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
