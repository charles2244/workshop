class CustomerReview {
  final String? id;
  final String? customerId;
  final int rating; // 1-5
  final String reviewText;
  final String? workId; // Changed from serviceId to workId
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerReview({
    this.id,
    this.customerId,
    required this.rating,
    required this.reviewText,
    this.workId, // Changed from serviceId to workId
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'rating': rating,
      'review_text': reviewText,
      'work_id': workId, // Changed from service_id to work_id
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static CustomerReview fromJson(Map<String, dynamic> json) {
    return CustomerReview(
      id: json['id']?.toString(),
      customerId: json['customer_id']?.toString(),
      rating: _parseInt(json['rating']) ?? 5,
      reviewText: json['review_text']?.toString() ?? '',
      workId: json['work_id']?.toString(), // Changed from service_id to work_id
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 5;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 5;
    if (value is num) return value.toInt();
    return 5;
  }
}