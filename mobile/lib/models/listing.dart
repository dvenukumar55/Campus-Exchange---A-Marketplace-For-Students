class Listing {
  final String listingId;
  final String collegeId;
  final String sellerId;
  final String sellerName;
  final String? sellerEmail;
  final String title;
  final String description;
  final String category;
  final double price;
  final String condition;
  final List<String> photoRefs;
  final String status; // draft, active, sold, closed
  final int viewCount;
  final int chatCount;
  final DateTime createdAt;
  final DateTime? closedAt;
  final String? closedReason;

  Listing({
    required this.listingId,
    required this.collegeId,
    required this.sellerId,
    required this.sellerName,
    this.sellerEmail,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.condition,
    required this.photoRefs,
    required this.status,
    this.viewCount = 0,
    this.chatCount = 0,
    required this.createdAt,
    this.closedAt,
    this.closedReason,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    List<String> photos = [];
    if (json['photoRefs'] is List) {
      photos = List<String>.from(json['photoRefs'].map((p) => p.toString()));
    }

    return Listing(
      listingId: json['listingId'] ?? '',
      collegeId: json['collegeId'] ?? '',
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? 'Verified Student',
      sellerEmail: json['sellerEmail'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Miscellaneous Academic',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      condition: json['condition'] ?? 'Good',
      photoRefs: photos,
      status: json['status'] ?? 'active',
      viewCount: json['viewCount'] ?? 0,
      chatCount: json['chatCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      closedAt: json['closedAt'] != null ? DateTime.tryParse(json['closedAt']) : null,
      closedReason: json['closedReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listingId': listingId,
      'collegeId': collegeId,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerEmail': sellerEmail,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'condition': condition,
      'photoRefs': photoRefs,
      'status': status,
      'viewCount': viewCount,
      'chatCount': chatCount,
      'createdAt': createdAt.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'closedReason': closedReason,
    };
  }

  bool get isActive => status == 'active';
  bool get isSold => status == 'sold';
  bool get isClosed => status == 'closed';
  String get primaryPhoto => photoRefs.isNotEmpty ? photoRefs.first : '';
}
