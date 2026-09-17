class Message {
  final String messageId;
  final String conversationId;
  final String listingId;
  final String collegeId;
  final String senderId;
  final String message;
  final DateTime createdAt;

  Message({
    required this.messageId,
    required this.conversationId,
    required this.listingId,
    required this.collegeId,
    required this.senderId,
    required this.message,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'] ?? '',
      conversationId: json['conversationId'] ?? '',
      listingId: json['listingId'] ?? '',
      collegeId: json['collegeId'] ?? '',
      senderId: json['senderId'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'listingId': listingId,
      'collegeId': collegeId,
      'senderId': senderId,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
