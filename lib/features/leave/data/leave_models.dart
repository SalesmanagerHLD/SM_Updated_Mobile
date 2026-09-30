abstract class LeaveRequestStatus {
  static const pending = 'PENDING';
  static const approved = 'APPROVED';
  static const rejected = 'REJECTED';
  static const cancelled = 'CANCELLED';
}

class LeaveTypeResponse {
  const LeaveTypeResponse({
    required this.id,
    required this.name,
    required this.code,
    required this.defaultAllocationDays,
    required this.active,
  });

  final String id;
  final String name;
  final String code;
  final num defaultAllocationDays;
  final bool active;

  factory LeaveTypeResponse.fromJson(Map<String, dynamic> json) => LeaveTypeResponse(
    id: json['id'] as String,
    name: json['name'] as String,
    code: json['code'] as String,
    defaultAllocationDays: json['defaultAllocationDays'] as num? ?? 0,
    active: json['active'] as bool? ?? true,
  );
}

/// `usedDays`/`remainingDays` are always server-computed from APPROVED
/// requests — never store or derive them client-side.
class LeaveBalanceResponse {
  const LeaveBalanceResponse({
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.allocatedDays,
    required this.carriedForwardDays,
    required this.usedDays,
    required this.remainingDays,
  });

  final String leaveTypeId;
  final String leaveTypeName;
  final num allocatedDays;
  final num carriedForwardDays;
  final num usedDays;
  final num remainingDays;

  num get totalAllocated => allocatedDays + carriedForwardDays;

  factory LeaveBalanceResponse.fromJson(Map<String, dynamic> json) => LeaveBalanceResponse(
    leaveTypeId: json['leaveTypeId'] as String,
    leaveTypeName: json['leaveTypeName'] as String,
    allocatedDays: json['allocatedDays'] as num? ?? 0,
    carriedForwardDays: json['carriedForwardDays'] as num? ?? 0,
    usedDays: json['usedDays'] as num? ?? 0,
    remainingDays: json['remainingDays'] as num? ?? 0,
  );
}

class LeaveRequestResponse {
  const LeaveRequestResponse({
    required this.id,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    this.reason,
    required this.status,
    this.decisionNote,
    required this.createdAt,
  });

  final String id;
  final String leaveTypeId;
  final String startDate;
  final String endDate;
  final num totalDays;
  final String? reason;
  final String status;
  final String? decisionNote;
  final String createdAt;

  factory LeaveRequestResponse.fromJson(Map<String, dynamic> json) => LeaveRequestResponse(
    id: json['id'] as String,
    leaveTypeId: json['leaveTypeId'] as String,
    startDate: json['startDate'] as String,
    endDate: json['endDate'] as String,
    totalDays: json['totalDays'] as num? ?? 0,
    reason: json['reason'] as String?,
    status: json['status'] as String,
    decisionNote: json['decisionNote'] as String?,
    createdAt: json['createdAt'] as String? ?? '',
  );
}

class LeaveRequestCreateRequest {
  const LeaveRequestCreateRequest({
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    this.reason,
  });

  final String leaveTypeId;
  final String startDate;
  final String endDate;
  final String? reason;

  Map<String, dynamic> toJson() => {
    'leaveTypeId': leaveTypeId,
    'startDate': startDate,
    'endDate': endDate,
    'reason': reason,
  };
}
