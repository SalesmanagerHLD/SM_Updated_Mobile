class EmployeeResponse {
  const EmployeeResponse({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.active,
    this.designationId,
    this.managerId,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final bool active;
  final String? designationId;
  final String? managerId;

  factory EmployeeResponse.fromJson(Map<String, dynamic> json) => EmployeeResponse(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String? ?? '',
    role: json['role'] as String,
    active: json['active'] as bool? ?? true,
    designationId: json['designationId'] as String?,
    managerId: json['managerId'] as String?,
  );

  String get firstName => fullName.split(' ').first;
}
