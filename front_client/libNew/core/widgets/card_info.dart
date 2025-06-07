//front_client\lib\core\widgets\card_info.dart
import 'package:flutter/material.dart';

class CardInfo extends StatelessWidget {
  final String title;
  final String description;
  final String color;

  const CardInfo({
    Key? key,
    required this.title,
    required this.description,
    required this.color,
  }) : super(key: key);

  Color _panelColor(String color) {
    switch (color) {
      case 'blue':
        return Colors.blue.shade100;
      case 'green':
        return Colors.green.shade100;
      case 'orange':
        return Colors.orange.shade100;
      case 'red':
        return Colors.red.shade100;
      case 'purple':
        return Colors.purple.shade100;
      case 'yellow':
        return Colors.yellow.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _panelColor(color),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
