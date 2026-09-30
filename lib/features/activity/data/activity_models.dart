abstract class ActivityType {
  static const leadCreated = 'LEAD_CREATED';
  static const statusChanged = 'STATUS_CHANGED';
  static const leadReassigned = 'LEAD_REASSIGNED';
  static const visitLogged = 'VISIT_LOGGED';
  static const visitCompleted = 'VISIT_COMPLETED';
  static const visitMissed = 'VISIT_MISSED';
  static const leadLapsed = 'LEAD_LAPSED';
}

class ActivityResponse {
  const ActivityResponse({
    required this.id,
    required this.leadId,
    this.ownerId,
    required this.companyName,
    required this.type,
    this.actorId,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final String leadId;
  final String? ownerId;
  final String companyName;
  final String type;
  final String? actorId;
  final String description;
  final String createdAt;

  factory ActivityResponse.fromJson(Map<String, dynamic> json) => ActivityResponse(
    id: json['id'] as String,
    leadId: json['leadId'] as String,
    ownerId: json['ownerId'] as String?,
    companyName: json['companyName'] as String? ?? '',
    type: json['type'] as String,
    actorId: json['actorId'] as String?,
    description: json['description'] as String,
    createdAt: json['createdAt'] as String,
  );
}
