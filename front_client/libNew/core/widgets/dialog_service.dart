//front_client\lib\core\widgets\dialog_service.dart
import 'package:flutter/material.dart';

Future<void> showServiceDialog(
  BuildContext context, {
  required String title,
  required String description,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
