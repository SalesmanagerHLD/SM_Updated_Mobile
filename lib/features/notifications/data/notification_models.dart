import 'dart:convert';

abstract class NotificationType {
  static const leadReassigned = 'LEAD_REASSIGNED';
  static const visitMissed = 'VISIT_MISSED';
  static const leadLapsed = 'LEAD_LAPSED';
  static const leadLapsedDigest = 'LEAD_LAPSED_DIGEST';
  static const leaveRequestSubmitted = 'LEAVE_REQUEST_SUBMITTED';
  static const leaveRequestApproved = 'LEAVE_REQUEST_APPROVED';
  static const leaveRequestRejected = 'LEAVE_REQUEST_REJECTED';
  static const lowStock = 'LOW_STOCK';
}

class NotificationResponse {
  const NotificationResponse({
    required this.id,
    required this.type,
    required this.payloadRaw,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String type;

  /// Raw JSON string — shape varies per [type]; parsed on demand via
  /// [payload] rather than eagerly, since most callers only need `type` and
  /// `createdAt` to render the list.
  final String payloadRaw;
  final bool read;
  final String createdAt;

  Map<String, dynamic> get payload {
    try {
      return jsonDecode(payloadRaw) as Map<String, dynamic>;
    } catch (_) {
      return const {};
    }
  }

  factory NotificationResponse.fromJson(Map<String, dynamic> json) => NotificationResponse(
    id: json['id'] as String,
    type: json['type'] as String,
    payloadRaw: json['payload'] as String? ?? '{}',
    read: json['read'] as bool? ?? false,
    createdAt: json['createdAt'] as String? ?? '',
  );
}
