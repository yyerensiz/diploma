import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Общая информация',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 16),
          // Информационные панели
          Container(
            width: double.infinity,
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                InfoPanel(
                  title: 'Новая функция',
                  description: 'Теперь вы можете отслеживать статус заказа в реальном времени',
                  color: Colors.blue.shade100,
                ),
                SizedBox(width: 16),
                InfoPanel(
                  title: 'Акция',
                  description: 'Скидка 20% на первый заказ для новых пользователей',
                  color: Colors.green.shade100,
                ),
                SizedBox(width: 16),
                InfoPanel(
                  title: 'Важное обновление',
                  description: 'Добавлена возможность оплаты через государственные субсидии',
                  color: Colors.orange.shade100,
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Текущие заказы',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 3, // Временное количество для демонстрации
            itemBuilder: (context, index) {
              return OrderCard(
                serviceName: 'Помощь с домашним заданием',
                specialistName: 'Анна М.',
                status: 'В процессе',
                date: '15 марта, 15:00',
                onTap: () {
                  // Навигация к деталям заказа
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class InfoPanel extends StatelessWidget {
  final String title;
  final String description;
  final Color color;

  const InfoPanel({
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String serviceName;
  final String specialistName;
  final String status;
  final String date;
  final VoidCallback onTap;

  const OrderCard({
    required this.serviceName,
    required this.specialistName,
    required this.status,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                serviceName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Специалист: $specialistName'),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(status),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Дата: $date',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 