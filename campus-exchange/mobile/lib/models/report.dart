class Report {
  final String reportId;
  final String collegeId;
  final String listingId;
  final String reporterId;
  final String sellerId;
  final String reason;
  final String description;
  final String status;
  final String? reviewNotes;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  Report({
    required this.reportId,
    required this.collegeId,
    required this.listingId,
    required this.reporterId,
    required this.sellerId,
    required this.reason,
    required this.description,
    required this.status,
    this.reviewNotes,
    required this.createdAt,
    this.resolvedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['reportId'] ?? '',
      collegeId: json['collegeId'] ?? '',
      listingId: json['listingId'] ?? '',
      reporterId: json['reporterId'] ?? '',
      sellerId: json['sellerId'] ?? '',
      reason: json['reason'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'open',
      reviewNotes: json['reviewNotes'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      resolvedAt: json['resolvedAt'] != null ? DateTime.tryParse(json['resolvedAt']) : null,
    );
  }
}
