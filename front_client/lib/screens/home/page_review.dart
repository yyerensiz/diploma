//front_client\lib\screens\home\page_review.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/service_reviews.dart';

class ReviewFormPage extends StatefulWidget {
  final int orderId;
  final int specialistId;

  const ReviewFormPage({
    Key? key,
    required this.orderId,
    required this.specialistId,
  }) : super(key: key);

  @override
  _ReviewFormPageState createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  int _rating = 5;
  final _commentCtl = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await ReviewService().createReview(
        orderId: widget.orderId,
        specialistId: widget.specialistId.toString(),
        rating: _rating,
        comment: _commentCtl.text,
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('review_error'.tr(args: [e.toString()]))),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('review_title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('your_rating'.tr()),
            Slider(
              min: 1,
              max: 5,
              divisions: 4,
              label: '$_rating',
              value: _rating.toDouble(),
              onChanged: (v) => setState(() => _rating = v.toInt()),
            ),
            TextField(
              controller: _commentCtl,
              decoration: InputDecoration(labelText: 'comment_label'.tr()),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    child: Text('submit_review'.tr()),
                  ),
          ],
        ),
      ),
    );
  }
}