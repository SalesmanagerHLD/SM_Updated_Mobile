import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import 'attachment_models.dart';

class AttachmentRepository {
  AttachmentRepository(this._dio);

  final Dio _dio;

  Future<List<LeadAttachmentResponse>> list(String leadId) async {
    try {
      final response = await _dio.get('/leads/$leadId/attachments');
      return (response.data as List<dynamic>)
          .map((e) => LeadAttachmentResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Multipart field name must be exactly `file` (backend-enforced, 10MB
  /// cap, whitelisted content types) — see Phase 6 for the upload UI.
  Future<LeadAttachmentResponse> upload(String leadId, {required String filePath, required String fileName}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await _dio.post('/leads/$leadId/attachments', data: formData);
      return LeadAttachmentResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> delete(String attachmentId) async {
    try {
      await _dio.delete('/attachments/$attachmentId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
