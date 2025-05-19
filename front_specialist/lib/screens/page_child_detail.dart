// lib/screens/page_child_detail.dart
import 'package:flutter/material.dart';
import '../models/model_child.dart';

class ChildDetailPage extends StatelessWidget {
  final Child child;
  const ChildDetailPage({ required this.child });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(child.name)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  child.pfpUrl ?? 'https://via.placeholder.com/100',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Имя: ${child.name}',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Дата рождения: ${child.dateOfBirth.toLocal().toString().split(" ")[0]}',
                textAlign: TextAlign.center,
              ),
              if (child.bio != null && child.bio!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Биография:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  child.bio!,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
