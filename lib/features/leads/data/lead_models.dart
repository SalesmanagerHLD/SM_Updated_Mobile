/// `LeadStatus` enum values (plain strings, matching the backend's JSON
/// enum-name serialization).
abstract class LeadStatus {
  static const newStatus = 'NEW';
  static const contacted = 'CONTACTED';
  static const negotiation = 'NEGOTIATION';
  static const interested = 'INTERESTED';
  static const lost = 'LOST';
  static const closedWon = 'CLOSED_WON';
  static const lapsed = 'LAPSED';

  static const all = [
    newStatus,
    contacted,
    negotiation,
    interested,
    lost,
    closedWon,
    lapsed,
  ];

  static String label(String status) => switch (status) {
    newStatus => 'New',
    contacted => 'Contacted',
    negotiation => 'Negotiation',
    interested => 'Interested',
    lost => 'Lost',
    closedWon => 'Closed Won',
    lapsed => 'Lapsed',
    _ => status,
  };
}

// Visit type constants live in `features/visits/data/visit_models.dart`'s
// `VisitType` class — reused here (LeadCreateRequest.visitType) rather than
// duplicated.

/// Full `LeadResponse` shape from the backend. Every master-data reference
/// field (`industryId` etc.) has a paired free-text `*Other` sibling —
/// mutually exclusive, enforced server-side, never both set.
class LeadResponse {
  const LeadResponse({
    required this.id,
    required this.organizationId,
    required this.companyName,
    this.industryId,
    this.industryOther,
    this.businessTypeId,
    this.businessTypeOther,
    this.leadSourceId,
    this.leadSourceOther,
    this.turnover,
    required this.contactPerson,
    this.designationId,
    this.designationOther,
    required this.contactNo,
    this.email,
    this.stateId,
    this.stateOther,
    this.cityId,
    this.cityOther,
    this.address,
    this.requirements,
    this.interestLevelId,
    this.interestLevelOther,
    this.currentProductSolution,
    this.budgetRange,
    this.decisionMakerIdentified = false,
    this.objections,
    this.remarks,
    this.nextFollowupDate,
    this.expectedCloseDate,
    this.lostReasonId,
    this.lostReasonOther,
    required this.status,
    this.ownerId,
    this.createdBy,
    this.productIds = const [],
    this.productsOther,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String organizationId;
  final String companyName;
  final String? industryId;
  final String? industryOther;
  final String? businessTypeId;
  final String? businessTypeOther;
  final String? leadSourceId;
  final String? leadSourceOther;
  final num? turnover;
  final String contactPerson;
  final String? designationId;
  final String? designationOther;
  final String contactNo;
  final String? email;
  final String? stateId;
  final String? stateOther;
  final String? cityId;
  final String? cityOther;
  final String? address;
  final String? requirements;
  final String? interestLevelId;
  final String? interestLevelOther;
  final String? currentProductSolution;
  final String? budgetRange;
  final bool decisionMakerIdentified;
  final String? objections;
  final String? remarks;
  final String? nextFollowupDate;
  final String? expectedCloseDate;
  final String? lostReasonId;
  final String? lostReasonOther;
  final String status;
  final String? ownerId;
  final String? createdBy;
  final List<String> productIds;
  final String? productsOther;
  final String? createdAt;
  final String? updatedAt;

  bool get isLost => status == LeadStatus.lost;

  factory LeadResponse.fromJson(Map<String, dynamic> json) => LeadResponse(
    id: json['id'] as String,
    organizationId: json['organizationId'] as String? ?? '',
    companyName: json['companyName'] as String,
    industryId: json['industryId'] as String?,
    industryOther: json['industryOther'] as String?,
    businessTypeId: json['businessTypeId'] as String?,
    businessTypeOther: json['businessTypeOther'] as String?,
    leadSourceId: json['leadSourceId'] as String?,
    leadSourceOther: json['leadSourceOther'] as String?,
    turnover: json['turnover'] as num?,
    contactPerson: json['contactPerson'] as String,
    designationId: json['designationId'] as String?,
    designationOther: json['designationOther'] as String?,
    contactNo: json['contactNo'] as String,
    email: json['email'] as String?,
    stateId: json['stateId'] as String?,
    stateOther: json['stateOther'] as String?,
    cityId: json['cityId'] as String?,
    cityOther: json['cityOther'] as String?,
    address: json['address'] as String?,
    requirements: json['requirements'] as String?,
    interestLevelId: json['interestLevelId'] as String?,
    interestLevelOther: json['interestLevelOther'] as String?,
    currentProductSolution: json['currentProductSolution'] as String?,
    budgetRange: json['budgetRange'] as String?,
    decisionMakerIdentified: json['decisionMakerIdentified'] as bool? ?? false,
    objections: json['objections'] as String?,
    remarks: json['remarks'] as String?,
    nextFollowupDate: json['nextFollowupDate'] as String?,
    expectedCloseDate: json['expectedCloseDate'] as String?,
    lostReasonId: json['lostReasonId'] as String?,
    lostReasonOther: json['lostReasonOther'] as String?,
    status: json['status'] as String,
    ownerId: json['ownerId'] as String?,
    createdBy: json['createdBy'] as String?,
    productIds: (json['productIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    productsOther: json['productsOther'] as String?,
    createdAt: json['createdAt'] as String?,
    updatedAt: json['updatedAt'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'organizationId': organizationId,
    'companyName': companyName,
    'industryId': industryId,
    'industryOther': industryOther,
    'businessTypeId': businessTypeId,
    'businessTypeOther': businessTypeOther,
    'leadSourceId': leadSourceId,
    'leadSourceOther': leadSourceOther,
    'turnover': turnover,
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
    'interestLevelId': interestLevelId,
    'interestLevelOther': interestLevelOther,
    'currentProductSolution': currentProductSolution,
    'budgetRange': budgetRange,
    'decisionMakerIdentified': decisionMakerIdentified,
    'objections': objections,
    'remarks': remarks,
    'nextFollowupDate': nextFollowupDate,
    'expectedCloseDate': expectedCloseDate,
    'lostReasonId': lostReasonId,
    'lostReasonOther': lostReasonOther,
    'status': status,
    'ownerId': ownerId,
    'createdBy': createdBy,
    'productIds': productIds,
    'productsOther': productsOther,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

/// Body for `POST /leads`. `logAsVisitToday`/`visitType` optionally
/// auto-logs a completed Visit for today in the same call.
class LeadCreateRequest {
  const LeadCreateRequest({
    required this.companyName,
    required this.contactPerson,
    required this.contactNo,
    this.businessTypeId,
    this.businessTypeOther,
    this.designationId,
    this.designationOther,
    this.stateId,
    this.stateOther,
    this.cityId,
    this.cityOther,
    this.productIds = const [],
    this.interestLevelId,
    this.interestLevelOther,
    this.decisionMakerIdentified = false,
    this.nextFollowupDate,
    this.expectedCloseDate,
    this.remarks,
    this.industryId,
    this.industryOther,
    this.leadSourceId,
    this.leadSourceOther,
    this.turnover,
    this.email,
    this.address,
    this.currentProductSolution,
    this.budgetRange,
    this.logAsVisitToday = false,
    this.visitType,
  });

  final String companyName;
  final String contactPerson;
  final String contactNo;
  final String? businessTypeId;
  final String? businessTypeOther;
  final String? designationId;
  final String? designationOther;
  final String? stateId;
  final String? stateOther;
  final String? cityId;
  final String? cityOther;
  final List<String> productIds;
  final String? interestLevelId;
  final String? interestLevelOther;
  final bool decisionMakerIdentified;
  final String? nextFollowupDate;
  final String? expectedCloseDate;
  final String? remarks;
  final String? industryId;
  final String? industryOther;
  final String? leadSourceId;
  final String? leadSourceOther;
  final num? turnover;
  final String? email;
  final String? address;
  final String? currentProductSolution;
  final String? budgetRange;
  final bool logAsVisitToday;
  final String? visitType;

  Map<String, dynamic> toJson() => {
    'companyName': companyName,
    'contactPerson': contactPerson,
    'contactNo': contactNo,
    'businessTypeId': businessTypeId,
    'businessTypeOther': businessTypeOther,
    'designationId': designationId,
    'designationOther': designationOther,
    'stateId': stateId,
    'stateOther': stateOther,
    'cityId': cityId,
    'cityOther': cityOther,
    'productIds': productIds,
    'interestLevelId': interestLevelId,
    'interestLevelOther': interestLevelOther,
    'decisionMakerIdentified': decisionMakerIdentified,
    'nextFollowupDate': nextFollowupDate,
    'expectedCloseDate': expectedCloseDate,
    'remarks': remarks,
    'industryId': industryId,
    'industryOther': industryOther,
    'leadSourceId': leadSourceId,
    'leadSourceOther': leadSourceOther,
    'turnover': turnover,
    'email': email,
    'address': address,
    'currentProductSolution': currentProductSolution,
    'budgetRange': budgetRange,
    'logAsVisitToday': logAsVisitToday,
    'visitType': visitType,
  };
}

class LeadStatusUpdateRequest {
  const LeadStatusUpdateRequest({required this.status, this.lostReasonId, this.lostReasonOther});

  final String status;
  final String? lostReasonId;
  final String? lostReasonOther;

  Map<String, dynamic> toJson() => {
    'status': status,
    'lostReasonId': lostReasonId,
    'lostReasonOther': lostReasonOther,
  };
}

class LeadDuplicateMatch {
  const LeadDuplicateMatch({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.contactNo,
    this.ownerId,
  });

  final String id;
  final String companyName;
  final String contactPerson;
  final String contactNo;
  final String? ownerId;

  factory LeadDuplicateMatch.fromJson(Map<String, dynamic> json) => LeadDuplicateMatch(
    id: json['id'] as String,
    companyName: json['companyName'] as String,
    contactPerson: json['contactPerson'] as String,
    contactNo: json['contactNo'] as String,
    ownerId: json['ownerId'] as String?,
  );
}
