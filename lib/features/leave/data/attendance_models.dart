abstract class AttendanceStatus {
  static const present = 'PRESENT';
  static const absent = 'ABSENT';
  static const onLeave = 'ON_LEAVE';
  static const holiday = 'HOLIDAY';
  static const weekend = 'WEEKEND';
}

class AttendanceRecordResponse {
  const AttendanceRecordResponse({
    required this.id,
    required this.attendanceDate,
    this.checkInAt,
    this.checkOutAt,
  });

  final String id;
  final String attendanceDate;
  final String? checkInAt;
  final String? checkOutAt;

  bool get isClockedIn => checkInAt != null && checkOutAt == null;

  factory AttendanceRecordResponse.fromJson(Map<String, dynamic> json) => AttendanceRecordResponse(
    id: json['id'] as String,
    attendanceDate: json['attendanceDate'] as String,
    checkInAt: json['checkInAt'] as String?,
    checkOutAt: json['checkOutAt'] as String?,
  );
}

class AttendanceDayResponse {
  const AttendanceDayResponse({
    required this.date,
    required this.status,
    this.checkInAt,
    this.checkOutAt,
  });

  final String date;
  final String status;
  final String? checkInAt;
  final String? checkOutAt;

  factory AttendanceDayResponse.fromJson(Map<String, dynamic> json) => AttendanceDayResponse(
    date: json['date'] as String,
    status: json['status'] as String,
    checkInAt: json['checkInAt'] as String?,
    checkOutAt: json['checkOutAt'] as String?,
  );
}
