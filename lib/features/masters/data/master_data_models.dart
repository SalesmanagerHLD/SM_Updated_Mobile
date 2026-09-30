/// One master-data item — `GET /masters/{type}` returns a flat list of
/// these. `parentId` is populated for `CITY` rows (pointing at their
/// `STATE` row) and null for every other type.
class MasterDataItem {
  const MasterDataItem({
    required this.id,
    required this.type,
    required this.code,
    required this.label,
    required this.sortOrder,
    required this.active,
    this.parentId,
  });

  final String id;
  final String type;
  final String code;
  final String label;
  final int sortOrder;
  final bool active;
  final String? parentId;

  factory MasterDataItem.fromJson(Map<String, dynamic> json) => MasterDataItem(
    id: json['id'] as String,
    type: json['type'] as String,
    code: json['code'] as String,
    label: json['label'] as String,
    sortOrder: json['sortOrder'] as int? ?? 0,
    active: json['active'] as bool? ?? true,
    parentId: json['parentId'] as String?,
  );
}

/// The 11 `MasterType` enum values, as the exact `{type}` path segment
/// string `GET /masters/{type}` expects.
abstract class MasterType {
  static const industry = 'INDUSTRY';
  static const city = 'CITY';
  static const product = 'PRODUCT';
  static const businessType = 'BUSINESS_TYPE';
  static const designation = 'DESIGNATION';
  static const visitPurpose = 'VISIT_PURPOSE';
  static const nextAction = 'NEXT_ACTION';
  static const lostReason = 'LOST_REASON';
  static const interestLevel = 'INTEREST_LEVEL';
  static const leadSource = 'LEAD_SOURCE';
  static const state = 'STATE';
}

/// `INTEREST_LEVEL` master rows use fixed codes the app's business logic
/// depends on (Hot-gates-Status, interest dot colors) — never the
/// admin-editable label.
abstract class InterestLevelCode {
  static const hot = 'HOT';
  static const warm = 'WARM';
  static const cold = 'COLD';
}
