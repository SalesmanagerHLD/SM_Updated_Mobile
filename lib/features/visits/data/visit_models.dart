abstract class VisitStatus {
  static const planned = 'PLANNED';
  static const completed = 'COMPLETED';
  static const missed = 'MISSED';

  static String label(String status) => switch (status) {
    planned => 'Planned',
    completed => 'Completed',
    missed => 'Missed',
    _ => status,
  };
}

abstract class VisitType {
  static const field = 'FIELD';
  static const telephonic = 'TELEPHONIC';

  static String label(String type) =>
      type == telephonic ? 'Telephonic Visit' : 'Field Visit';
}

/// Full `VisitResponse` shape. Fields supplied when creating/editing a
/// Visit (contactPerson, designationId, contactNo, email, cityId, address,
/// budgetRange, interestLevelId) sync back onto the parent Lead
/// server-side — the mobile client never needs a separate `PUT /leads/{id}`
/// after a Visit edits these.
class VisitResponse {
  const VisitResponse({
    required this.id,
    required this.organizationId,
    required this.leadId,
    required this.visitDate,
    this.scheduledTime,
    required this.visitType,
    this.purposeId,
    this.purposeOther,
    this.interestLevelId,
    this.interestLevelOther,
    this.contactPerson,
    this.designationId,
    this.designationOther,
    this.contactNo,
    this.email,
    this.stateId,
    this.stateOther,
    this.cityId,
    this.cityOther,
    this.address,
    this.requirements,
    this.budgetRange,
    this.decisionMakerIdentified = false,
    this.objections,
    this.remarks,
    this.nextVisitDate,
    required this.status,
    this.createdBy,
    this.productIds = const [],
    this.productsOther,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String organizationId;
  final String leadId;
  final String visitDate;
  final String? scheduledTime;
  final String visitType;
  final String? purposeId;
  final String? purposeOther;
  final String? interestLevelId;
  final String? interestLevelOther;
  final String? contactPerson;
  final String? designationId;
  final String? designationOther;
  final String? contactNo;
  final String? email;
  final String? stateId;
  final String? stateOther;
  final String? cityId;
  final String? cityOther;
  final String? address;
  final String? requirements;
  final String? budgetRange;
  final bool decisionMakerIdentified;
  final String? objections;
  final String? remarks;
  final String? nextVisitDate;
  final String status;
  final String? createdBy;
  final List<String> productIds;
  final String? productsOther;
  final String? createdAt;
  final String? updatedAt;

  factory VisitResponse.fromJson(Map<String, dynamic> json) => VisitResponse(
    id: json['id'] as String,
    organizationId: json['organizationId'] as String? ?? '',
    leadId: json['leadId'] as String,
    visitDate: json['visitDate'] as String,
    scheduledTime: json['scheduledTime'] as String?,
    visitType: json['visitType'] as String,
    purposeId: json['purposeId'] as String?,
    purposeOther: json['purposeOther'] as String?,
    interestLevelId: json['interestLevelId'] as String?,
    interestLevelOther: json['interestLevelOther'] as String?,
    contactPerson: json['contactPerson'] as String?,
    designationId: json['designationId'] as String?,
    designationOther: json['designationOther'] as String?,
    contactNo: json['contactNo'] as String?,
    email: json['email'] as String?,
    stateId: json['stateId'] as String?,
    stateOther: json['stateOther'] as String?,
    cityId: json['cityId'] as String?,
    cityOther: json['cityOther'] as String?,
    address: json['address'] as String?,
    requirements: json['requirements'] as String?,
    budgetRange: json['budgetRange'] as String?,
    decisionMakerIdentified: json['decisionMakerIdentified'] as bool? ?? false,
    objections: json['objections'] as String?,
    remarks: json['remarks'] as String?,
    nextVisitDate: json['nextVisitDate'] as String?,
    status: json['status'] as String,
    createdBy: json['createdBy'] as String?,
    productIds: (json['productIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    productsOther: json['productsOther'] as String?,
    createdAt: json['createdAt'] as String?,
    updatedAt: json['updatedAt'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'organizationId': organizationId,
    'leadId': leadId,
    'visitDate': visitDate,
    'scheduledTime': scheduledTime,
    'visitType': visitType,
    'purposeId': purposeId,
    'purposeOther': purposeOther,
    'interestLevelId': interestLevelId,
    'interestLevelOther': interestLevelOther,
    'contactPerson': contactPerson,
    'designationId': designationId,
    'designationOther': designationOther,
    'contactNo': contactNo,
    'email': email,
    'stateId': stateId,
    'stateOther': stateOther,
    'cityId': cityId,
    'cityOther': cityOther,
    'address': address,
    'requirements': requirements,
    'budgetRange': budgetRange,
    'decisionMakerIdentified': decisionMakerIdentified,
    'objections': objections,
    'remarks': remarks,
    'nextVisitDate': nextVisitDate,
    'status': status,
    'createdBy': createdBy,
    'productIds': productIds,
    'productsOther': productsOther,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

/// Body for `POST /visits`. Only `leadId`/`visitDate`/`visitType` are
/// required — everything else optional, typically pre-filled from the
/// parent Lead by the form layer.
class VisitCreateRequest {
  const VisitCreateRequest({
    required this.leadId,
    required this.visitDate,
    required this.visitType,
    this.scheduledTime,
    this.purposeId,
    this.purposeOther,
    this.interestLevelId,
    this.interestLevelOther,
    this.contactPerson,
    this.designationId,
    this.designationOther,
    this.contactNo,
    this.email,
    this.stateId,
    this.stateOther,
    this.cityId,
    this.cityOther,
    this.address,
    this.budgetRange,
    this.decisionMakerIdentified = false,
    this.remarks,
    this.nextVisitDate,
    this.productIds = const [],
    this.status,
  });

  final String leadId;
  final String visitDate;
  final String visitType;
  final String? scheduledTime;
  final String? purposeId;
  final String? purposeOther;
  final String? interestLevelId;
  final String? interestLevelOther;
  final String? contactPerson;
  final String? designationId;
  final String? designationOther;
  final String? contactNo;
  final String? email;
  final String? stateId;
  final String? stateOther;
  final String? cityId;
  final String? cityOther;
  final String? address;
  final String? budgetRange;
  final bool decisionMakerIdentified;
  final String? remarks;
  final String? nextVisitDate;
  final List<String> productIds;

  /// Only meaningful on create, for the mockup's "log as completed"
  /// checkbox — omit/null to leave it PLANNED (the server default).
  final String? status;

  Map<String, dynamic> toJson() => {
    'leadId': leadId,
    'visitDate': visitDate,
    'visitType': visitType,
    'scheduledTime': scheduledTime,
    'purposeId': purposeId,
    'purposeOther': purposeOther,
    'interestLevelId': interestLevelId,
    'interestLevelOther': interestLevelOther,
    'contactPerson': contactPerson,
    'designationId': designationId,
    'designationOther': designationOther,
    'contactNo': contactNo,
    'email': email,
    'stateId': stateId,
    'stateOther': stateOther,
    'cityId': cityId,
    'cityOther': cityOther,
    'address': address,
    'budgetRange': budgetRange,
    'decisionMakerIdentified': decisionMakerIdentified,
    'remarks': remarks,
    'nextVisitDate': nextVisitDate,
    'productIds': productIds,
    if (status != null) 'status': status,
  };
}

class VisitSameDayMatch {
  const VisitSameDayMatch({required this.id, required this.visitType, this.purposeId});

  final String id;
  final String visitType;
  final String? purposeId;

  factory VisitSameDayMatch.fromJson(Map<String, dynamic> json) => VisitSameDayMatch(
    id: json['id'] as String,
    visitType: json['visitType'] as String,
    purposeId: json['purposeId'] as String?,
  );
}
