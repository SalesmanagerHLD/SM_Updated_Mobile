import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import 'employee_models.dart';

class EmployeeRepository {
  EmployeeRepository(this._dio);

  final Dio _dio;

  Future<EmployeeResponse> getById(String id) async {
    try {
      final response = await _dio.get('/employees/$id');
      return EmployeeResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
