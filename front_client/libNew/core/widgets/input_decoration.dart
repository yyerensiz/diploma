//front_client\lib\core\widgets\input_decoration.dart
import 'package:flutter/material.dart';

InputDecoration buildInputDecoration({
  required String labelText,
  IconData? prefixIcon,
  String? hintText,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  );
}
