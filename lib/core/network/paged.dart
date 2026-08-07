/// Mirrors Spring Data's `Page<T>` JSON shape (`content`, `totalElements`,
/// `totalPages`, `number` = current 0-based page, `size`, `last`) — every
/// list endpoint in the backend (`GET /leads`, `/visits`, `/notifications`,
/// `/activity`) returns this same envelope.
class Paged<T> {
  const Paged({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.number,
    required this.size,
    required this.last,
    this.fromCache = false,
  });

  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int number;
  final int size;
  final bool last;

  /// True when this result was served from the local cache after a network
  /// failure (see the repository read-through-cache pattern) rather than
  /// fetched fresh — screens use this to show a "showing offline data"
  /// caption distinct from the sync-pending/conflict banners.
  final bool fromCache;

  factory Paged.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    final content = (json['content'] as List<dynamic>? ?? [])
        .map((e) => fromJsonT(e as Map<String, dynamic>))
        .toList();
    return Paged(
      content: content,
      totalElements: json['totalElements'] as int? ?? content.length,
      totalPages: json['totalPages'] as int? ?? 1,
      number: json['number'] as int? ?? 0,
      size: json['size'] as int? ?? content.length,
      last: json['last'] as bool? ?? true,
    );
  }

  factory Paged.fromCacheList(List<T> content) => Paged(
    content: content,
    totalElements: content.length,
    totalPages: 1,
    number: 0,
    size: content.length,
    last: true,
    fromCache: true,
  );
}
