import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Уведомления'),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all),
            onPressed: () {
              // Отметить все как прочитанные
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          NotificationGroup(
            title: 'Новые',
            notifications: [
              NotificationItem(
                title: 'Новый отзыв',
                message: 'Специалист оставил отзыв о вашем заказе',
                time: '2 минуты назад',
                icon: Icons.star,
                isUnread: true,
              ),
              NotificationItem(
                title: 'Статус заказа',
                message: 'Ваш заказ №123 успешно выполнен',
                time: '1 час назад',
                icon: Icons.check_circle,
                isUnread: true,
              ),
            ],
          ),
          NotificationGroup(
            title: 'Ранее',
            notifications: [
              NotificationItem(
                title: 'Специалист принял заказ',
                message: 'Анна М. приняла ваш заказ на помощь с домашним заданием',
                time: 'Вчера',
                icon: Icons.person,
                isUnread: false,
              ),
              NotificationItem(
                title: 'Напоминание',
                message: 'Завтра в 15:00 у вас запланирован заказ',
                time: '2 дня назад',
                icon: Icons.calendar_today,
                isUnread: false,
              ),
              NotificationItem(
                title: 'Акция',
                message: 'Получите скидку 20% на первый заказ',
                time: 'Неделю назад',
                icon: Icons.local_offer,
                isUnread: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NotificationGroup extends StatelessWidget {
  final String title;
  final List<NotificationItem> notifications;

  const NotificationGroup({
    required this.title,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ),
        ...notifications,
      ],
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final bool isUnread;

  const NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.isUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isUnread ? Colors.blue.shade50 : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isUnread
              ? Theme.of(context).primaryColor
              : Theme.of(context).disabledColor,
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(message),
            SizedBox(height: 4),
            Text(
              time,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        onTap: () {
          // Обработка нажатия на уведомление
        },
      ),
    );
  }
} 