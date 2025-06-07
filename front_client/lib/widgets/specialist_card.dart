//front_client\lib\widgets\specialist_card.dart
import 'package:flutter/material.dart';

class SpecialistCard extends StatelessWidget {
  final String name;
  final double rating;
  final String imageUrl;
  final VoidCallback onTap;

  const SpecialistCard({
    required this.name,
    required this.rating,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
