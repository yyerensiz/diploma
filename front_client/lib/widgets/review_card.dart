// Review Card Widget

import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final String authorName;
  final double rating;
  final String date;
  final String text;

  const ReviewCard({
    required this.authorName,
    required this.rating,
    required this.date,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  authorName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    const Icon(Icons.star,
                        size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(rating.toString()),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(text),
          ],
        ),
      ),
    );
  }
}