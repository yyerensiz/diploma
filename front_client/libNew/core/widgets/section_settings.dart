//front_client\lib\core\widgets\section_settings.dart
import 'package:flutter/material.dart';

class SectionSettings extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SectionSettings({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ),
        Material(
          color: Colors.white,
          child: Column(children: children),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
