import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';

/// `FeatureEntitlement` enum values relevant to the mobile app. Others exist
/// server-side (`CALENDAR_SYNC`) but gate nothing here.
abstract class FeatureEntitlement {
  static const employeeLeaveManagement = 'EMPLOYEE_LEAVE_MANAGEMENT';
  static const teamVisibility = 'TEAM_VISIBILITY';
  static const pushNotifications = 'PUSH_NOTIFICATIONS';
  static const inventoryManagement = 'INVENTORY_MANAGEMENT';
}

class EntitlementRepository {
  EntitlementRepository(this._dio);

  final Dio _dio;

  /// `GET /organizations/me/entitlements` returns a plain JSON array of
  /// enum-name strings (e.g. `["TEAM_VISIBILITY","PUSH_NOTIFICATIONS"]`),
  /// not objects.
  Future<Set<String>> getMyEntitlements() async {
    try {
      final response = await _dio.get('/organizations/me/entitlements');
      return (response.data as List<dynamic>).map((e) => e as String).toSet();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
