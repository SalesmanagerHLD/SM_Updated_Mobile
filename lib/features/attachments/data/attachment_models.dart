class LeadAttachmentResponse {
  const LeadAttachmentResponse({
    required this.id,
    required this.leadId,
    required this.fileName,
    required this.contentType,
    required this.fileSize,
    required this.createdAt,
  });

  final String id;
  final String leadId;
  final String fileName;
  final String contentType;
  final int fileSize;
  final String createdAt;

  String get sizeLabel {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get typeBadge {
    if (contentType.contains('pdf')) return 'PDF';
    if (contentType.contains('word')) return 'DOC';
    if (contentType.contains('sheet') || contentType.contains('excel')) return 'XLS';
    if (contentType.startsWith('image/')) return 'IMG';
    return 'FILE';
  }

  factory LeadAttachmentResponse.fromJson(Map<String, dynamic> json) => LeadAttachmentResponse(
    id: json['id'] as String,
    leadId: json['leadId'] as String,
    fileName: json['fileName'] as String,
    contentType: json['contentType'] as String? ?? '',
    fileSize: json['fileSize'] as int? ?? 0,
    createdAt: json['createdAt'] as String? ?? '',
  );
}
