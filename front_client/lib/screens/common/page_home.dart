import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:front_client/models/model_order.dart';
import 'package:front_client/services/service_orders.dart';
import 'package:front_client/models/model_info.dart';
import 'package:front_client/services/service_info.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Order>>? _ordersFuture;
  late Future<List<InfoPanelModel>> _infoPanelsFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _infoPanelsFuture = InfoPanelService().fetchInfoPanels();
  }

  Future<void> _loadOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();

    print('Token: $token');

    if (token != null) {
      setState(() {
        _ordersFuture = OrderService().fetchClientOrders(token);
      });
    } else {
      setState(() {
        _ordersFuture = Future.value([]);
      });
    }
  }

  Color _panelColor(String color) {
    switch (color) {
      case 'blue': return Colors.blue.shade100;
      case 'green': return Colors.green.shade100;
      case 'orange': return Colors.orange.shade100;
      case 'red': return Colors.red.shade100;
      case 'purple': return Colors.purple.shade100;
      case 'yellow': return Colors.yellow.shade100;
      default: return Colors.grey.shade200;
    }
  }

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
          SizedBox(
            width: double.infinity,
            height: 200,
            child: FutureBuilder<List<InfoPanelModel>>(
              future: _infoPanelsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());
                if (snapshot.hasError)
                  return Text('Ошибка загрузки информации');
                final panels = snapshot.data ?? [];
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: panels.length,
                  separatorBuilder: (_, __) => SizedBox(width: 16),
                  itemBuilder: (context, i) {
                    final p = panels[i];
                    return InfoPanel(
                      title: p.title,
                      description: p.description,
                      color: _panelColor(p.color),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Текущие заказы',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          FutureBuilder<List<Order>>(
            future: _ordersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Ошибка загрузки заказов');
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('Нет текущих заказов');
              }
              final orders = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return OrderCard(
                    serviceName: order.serviceType,
                    specialistName: order.specialistName ?? '-',
                    status: order.status,
                    date: _formatOrderDate(order.scheduledFor),
                    onTap: () {
                      // TODO: Навигация к деталям заказа
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatOrderDate(DateTime date) {
    final localDate = date.toLocal();
    return '${localDate.day} ${_russianMonth(localDate.month)}, '
        '${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}';
  }

  String _russianMonth(int month) {
    const months = [
      '', 'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return months[month];
  }
}

// InfoPanel and OrderCard can stay the same as before
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

// Your existing OrderCard widget here
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
