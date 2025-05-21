//front_client\lib\services\service_reviews.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/model_review.dart';

class ReviewService {
  final _baseUrl = 'http://192.168.0.230:5000/api/reviews';

  Future<Review> createReview(String orderId, int rating, String comment, String? specialistId) async {
    final user = FirebaseAuth.instance.currentUser!;
    final token = await user.getIdToken();
    final body = jsonEncode({
      'specialist_id': specialistId,
      'order_id': orderId,
      'rating': rating,
      'comment': comment,
    });

    final resp = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: body,
    );

    if (resp.statusCode == 201) {
      return Review.fromJson(jsonDecode(resp.body)['review']);
    } else {
      throw Exception('Failed to post review: ${resp.body}');
    }
  }

  Future<List<Review>> fetchSpecialistReviews(int specialistId) async {
    final token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final url = '$_baseUrl/specialist/$specialistId';

    final resp = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    print('GET $url → ${resp.statusCode}');
    print('body: ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('Failed to load reviews: ${resp.statusCode}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final list = data['reviews'] as List<dynamic>? ?? [];
    return list.map((j) => Review.fromJson(j as Map<String, dynamic>)).toList();
  }
}
