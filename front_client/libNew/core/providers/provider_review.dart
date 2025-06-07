//front_client\lib\core\providers\provider_review.dart
import 'package:flutter/material.dart';
import '../services/service_review.dart';
import '../models/model_review.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();
  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Review> get reviews => List.unmodifiable(_reviews);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchReviewsForSpecialist(int specialistId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _reviews = await _reviewService.fetchSpecialistReviews(specialistId);
    } catch (e) {
      _reviews = [];
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postReview({
    required int orderId,
    required String specialistId,
    required int rating,
    required String comment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newReview = await _reviewService.createReview(
        orderId: orderId,
        rating: rating,
        comment: comment,
        specialistId: specialistId,
      );
      _reviews.insert(0, newReview);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
