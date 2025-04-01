import 'package:flutter/material.dart';

class SpecialistProfilePage extends StatelessWidget {
  final String name;
  final String specialization;
  final double rating;
  final String imageUrl;
  final String description;

  const SpecialistProfilePage({
    required this.name,
    required this.specialization,
    required this.rating,
    required this.imageUrl,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль специалиста'),
        actions: [
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {
              // Навигация к чату со специалистом
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                  SizedBox(height: 16),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    specialization,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'О специалисте',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(description),
                  SizedBox(height: 24),
                  Text(
                    'Отзывы',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return ReviewCard(
                        authorName: 'Клиент ${index + 1}',
                        rating: 4.5,
                        date: '10 марта 2024',
                        text: 'Очень хороший специалист, пунктуальный и ответственный. Дети в восторге!',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              // Навигация к странице создания заказа
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Заказать услугу',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
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
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(rating.toString()),
                  ],
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              date,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 8),
            Text(text),
          ],
        ),
      ),
    );
  }
} 