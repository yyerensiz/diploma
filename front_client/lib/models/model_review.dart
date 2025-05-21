//front_client\lib\models\model_review.dart
class Review {
  final int id;
  final int orderId;
  final int clientId;
  final String clientName;
  final String specialistId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.orderId,
    required this.clientId,
    required this.clientName,  
    required this.specialistId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      orderId: json['order_id'],
      clientId: json['client_id'],
      clientName: json['client']?['full_name'] as String? ?? 'Client',
      specialistId: json['specialist_id'].toString(),
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'specialist_id': specialistId,
        'order_id': orderId,
        'rating': rating,
        'comment': comment,
      };
}
