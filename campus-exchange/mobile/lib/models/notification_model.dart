class NotificationModel {
  final String notificationId;
  final String recipientStudentId;
  final String collegeId;
  final String listingId;
  final String senderStudentId;
  final String senderName;
  final String listingTitle;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    required this.recipientStudentId,
    required this.collegeId,
    required this.listingId,
    this.senderStudentId = '',
    this.senderName = '',
    this.listingTitle = '',
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] ?? '',
      recipientStudentId: json['recipientStudentId'] ?? '',
      collegeId: json['collegeId'] ?? '',
      listingId: json['listingId'] ?? '',
      senderStudentId: json['senderStudentId'] ?? '',
      senderName: json['senderName'] ?? '',
      listingTitle: json['listingTitle'] ?? '',
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      type: json['type'] ?? 'NEW_LISTING',
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'recipientStudentId': recipientStudentId,
      'collegeId': collegeId,
      'listingId': listingId,
      'senderStudentId': senderStudentId,
      'senderName': senderName,
      'listingTitle': listingTitle,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return NotificationModel(
      notificationId: notificationId,
      recipientStudentId: recipientStudentId,
      collegeId: collegeId,
      listingId: listingId,
      senderStudentId: senderStudentId,
      senderName: senderName,
      listingTitle: listingTitle,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
    );
  }
}
