//front_client\lib\screens\common\page_review.dart
import 'package:flutter/material.dart';
import '../../services/service_reviews.dart';

class ReviewFormPage extends StatefulWidget {
  final String orderId;
  const ReviewFormPage(this.orderId, this.specialistId);
  final String specialistId;

  @override
  _ReviewFormPageState createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  int _rating = 5;
  final _commentCtl = TextEditingController();
  bool _loading = false;

  void _submit() async {
    setState(() => _loading = true);
    try {
      await ReviewService()
          .createReview(widget.orderId, _rating, _commentCtl.text, widget.specialistId);
      Navigator.pop(context, true); // signal “review posted”
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: Text('Оставить отзыв')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Ваша оценка'),
            // you can use a stars picker package here; for simplicity:
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
              decoration: InputDecoration(labelText: 'Комментарий'),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit, child: Text('Отправить отзыв')),
          ],
        ),
      ),
    );
  }
}
