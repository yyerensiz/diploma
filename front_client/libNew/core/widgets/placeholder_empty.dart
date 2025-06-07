//front_client\lib\core\widgets\placeholder_empty.dart
import 'package:flutter/material.dart';

class PlaceholderEmpty extends StatelessWidget {
  final String message;

  const PlaceholderEmpty({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}
