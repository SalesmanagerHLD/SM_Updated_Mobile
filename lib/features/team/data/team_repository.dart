import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import 'team_models.dart';

class TeamRepository {
  TeamRepository(this._dio);

  final Dio _dio;

  Future<List<TeamMemberProgress>> getTeamProgress() async {
    try {
      final response = await _dio.get('/reports/team-progress');
      final members = (response.data as Map<String, dynamic>)['members'] as List<dynamic>;
      return members.map((e) => TeamMemberProgress.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
