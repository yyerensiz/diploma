import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Профиль',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://i.pinimg.com/originals/c2/a0/82/c2a0829e2d070defdc51a5d81bb5988f.png'),
              ),
              SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yryskeldi Yerensiz',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text('Возраст: 20 лет'),
                    Text('Email: Yryskeldi@email.com'),
                    Text('Телефон: +7 (777) 987-34-25'),
                    Text('Адрес: G. Mustafin'),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Навигация к странице редактирования профиля
                      },
                      child: Text('Редактировать'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          Text(
            'Мои дети',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          Container(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ChildCard(
                  name: 'Qazyna',
                  age: '7 лет',
                  imageUrl: 'https://example.com/child1.jpg',
                ),
                SizedBox(width: 16),
                ChildCard(
                  name: 'Nurgeldi',
                  age: '5 лет',
                  imageUrl: 'https://example.com/child2.jpg',
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          ProfileMenuButton(
            icon: Icons.description,
            title: 'Документы',
            onTap: () {
              // Навигация к странице документов
            },
          ),
          ProfileMenuButton(
            icon: Icons.history,
            title: 'История заказов',
            onTap: () {
              // Навигация к истории заказов
            },
          ),
          ProfileMenuButton(
            icon: Icons.payment,
            title: 'Платежные данные',
            onTap: () {
              // Навигация к платежным данным
            },
          ),
          ProfileMenuButton(
            icon: Icons.security,
            title: 'Настройки безопасности',
            onTap: () {
              // Навигация к настройкам безопасности
            },
          ),
        ],
      ),
    );
  }
}

class ChildCard extends StatelessWidget {
  final String name;
  final String age;
  final String imageUrl;

  const ChildCard({
    required this.name,
    required this.age,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl),
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            age,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class ProfileMenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
} 