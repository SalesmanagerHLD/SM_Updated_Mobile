class TeamMemberProgress {
  const TeamMemberProgress({
    required this.employeeId,
    required this.employeeName,
    required this.leadCountsByStatus,
    required this.totalLeads,
    required this.visitsDueToday,
    required this.visitsUpcoming,
    this.lastActivityAt,
  });

  final String employeeId;
  final String employeeName;
  final Map<String, int> leadCountsByStatus;
  final int totalLeads;
  final int visitsDueToday;
  final int visitsUpcoming;
  final String? lastActivityAt;

  int get wonCount => leadCountsByStatus['CLOSED_WON'] ?? 0;

  String get initials {
    final parts = employeeName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  factory TeamMemberProgress.fromJson(Map<String, dynamic> json) => TeamMemberProgress(
    employeeId: json['employeeId'] as String,
    employeeName: json['employeeName'] as String,
    leadCountsByStatus: (json['leadCountsByStatus'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(k, (v as num).toInt()),
    ),
    totalLeads: (json['totalLeads'] as num?)?.toInt() ?? 0,
    visitsDueToday: (json['visitsDueToday'] as num?)?.toInt() ?? 0,
    visitsUpcoming: (json['visitsUpcoming'] as num?)?.toInt() ?? 0,
    lastActivityAt: json['lastActivityAt'] as String?,
  );
}
