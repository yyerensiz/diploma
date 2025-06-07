//front_client\lib\core\services\service_review.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/model_review.dart';
import '../config.dart';

class ReviewService {
  Future<Review> createReview({
    required int orderId,
    required int rating,
    required String comment,
    required String specialistId,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;
    final token = await user.getIdToken();
    final body = jsonEncode({
      'specialist_id': specialistId,
      'order_id': orderId,
      'rating': rating,
      'comment': comment,
    });
    final resp = await http.post(
      Uri.parse(URL_REVIEWS),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    if (resp.statusCode == 201) {
      return Review.fromJson(jsonDecode(resp.body)['review']);
    }
    throw Exception('Failed to post review: ${resp.body}');
  }

  Future<List<Review>> fetchSpecialistReviews(int specialistId) async {
    final user = FirebaseAuth.instance.currentUser!;
    final token = await user.getIdToken();
    final url = '$URL_REVIEWS/specialist/$specialistId';
    final resp = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to load reviews: ${resp.statusCode}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final list = data['reviews'] as List<dynamic>? ?? [];
    return list.map((j) => Review.fromJson(j as Map<String, dynamic>)).toList();
  }
}
