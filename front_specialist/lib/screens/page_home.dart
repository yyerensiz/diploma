import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:front_specialist/screens/page_child_detail.dart';
import 'package:http/http.dart' as http;
import '../models/model_order.dart';
import '../models/model_child.dart';
import '../services/service_order.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<OrderModel> orders = [];
  bool isLoading = true;
  int? specialistId;

  @override
  void initState() {
    super.initState();
    _loadSpecialistIdAndOrders();
  }

  Future<void> _loadSpecialistIdAndOrders() async {
    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final token = await user.getIdToken();
    final profileResp = await http.get(
      Uri.parse('http://192.168.0.230:5000/api/specialists/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (profileResp.statusCode == 200) {
      final data = Map<String, dynamic>.from(jsonDecode(profileResp.body));
      final int specId = data['id'] ?? data['specialist_id'];
      setState(() => specialistId = specId);
      await fetchOrders(specId);
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchOrders(int specialistId) async {
    try {
      orders = await OrderService().fetchSpecialistOrders(specialistId);
    } catch (e) {
      orders = [];
    }
    setState(() => isLoading = false);
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      await OrderService().updateOrderStatus(orderId, status);
      if (specialistId != null) {
        await fetchOrders(specialistId!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  void openOrderDetails(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailPage(
          order: order,
          onAccept: () => updateOrderStatus(order.id, 'accepted'),
          onReject: () => updateOrderStatus(order.id, 'cancelled'),
          onComplete: () => updateOrderStatus(order.id, 'completed'),
        ),
      ),
    ).then((_) {
      if (specialistId != null) fetchOrders(specialistId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Мои заказы')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(child: Text('Нет доступных заказов'))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (ctx, i) {
                    final order = orders[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.serviceType,
                                style: Theme.of(ctx).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text('Описание: ${order.description}'),
                            Text('Статус: ${order.status}'),
                            Text(
                              'Дата: ${order.scheduledFor.toLocal().toString().split(".")[0]}',
                            ),
                            const SizedBox(height: 8),
                            if (order.children.isNotEmpty) ...[
                              Text('Дети:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 70,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: order.children.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                                  itemBuilder: (ctx2, j) {
                                    final child = order.children[j];
                                    return GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChildDetailPage(child: child),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundImage: NetworkImage(
                                              child.pfpUrl ?? 'https://via.placeholder.com/50',
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          SizedBox(
                                            width: 60,
                                            child: Text(
                                              child.name,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: Theme.of(ctx).textTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => openOrderDetails(order),
                                child: const Text('Подробнее'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class OrderDetailPage extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onComplete;

  const OrderDetailPage({
    required this.order,
    required this.onAccept,
    required this.onReject,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    // decide which buttons to show
    List<Widget> actions = [];
    if (order.status == 'pending') {
      actions = [
        ElevatedButton(onPressed: onAccept, child: Text('Принять')),
        ElevatedButton(
          onPressed: onReject,
          child: Text('Отклонить'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ];
    } else if (order.status == 'in_progress') {
      actions = [
        ElevatedButton(onPressed: onComplete, child: Text('Завершить')),
      ];
    }

    return Scaffold(
      appBar: AppBar(title: Text('Заказ №${order.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Услуга: ${order.serviceType}', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Описание: ${order.description}'),
            const SizedBox(height: 8),
            Text('Статус: ${order.status}'),
            const SizedBox(height: 8),
            Text('Дата: ${order.scheduledFor.toLocal().toString().split(".")[0]}'),
            const SizedBox(height: 16),
            Text('Дети:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...order.children.map((child) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      child.pfpUrl ?? 'https://via.placeholder.com/50',
                    ),
                  ),
                  title: Text(child.name),
                  subtitle: Text('Дата рождения: ${child.dateOfBirth.toLocal().toString().split(" ")[0]}'),
                )),
            const SizedBox(height: 24),
            if (actions.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: actions,
              ),
          ],
        ),
      ),
    );
  }
}
