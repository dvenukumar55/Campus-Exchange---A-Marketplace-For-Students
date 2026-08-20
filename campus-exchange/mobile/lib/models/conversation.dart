class Conversation {
  final String conversationId;
  final String listingId;
  final String collegeId;
  final String buyerId;
  final String sellerId;
  final String lastMessage;
  final String? lastMessageSenderId;
  final DateTime lastMessageAt;
  final String? listingTitle;
  final double? listingPrice;
  final String? listingPhoto;
  final String? listingStatus;

  Conversation({
    required this.conversationId,
    required this.listingId,
    required this.collegeId,
    required this.buyerId,
    required this.sellerId,
    required this.lastMessage,
    this.lastMessageSenderId,
    required this.lastMessageAt,
    this.listingTitle,
    this.listingPrice,
    this.listingPhoto,
    this.listingStatus,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      conversationId: json['conversationId'] ?? '',
      listingId: json['listingId'] ?? '',
      collegeId: json['collegeId'] ?? '',
      buyerId: json['buyerId'] ?? '',
      sellerId: json['sellerId'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      lastMessageSenderId: json['lastMessageSenderId'],
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt']) ?? DateTime.now()
          : DateTime.now(),
      listingTitle: json['listingTitle'],
      listingPrice: json['listingPrice'] != null ? (json['listingPrice'] as num).toDouble() : null,
      listingPhoto: json['listingPhoto'],
      listingStatus: json['listingStatus'],
    );
  }
}
