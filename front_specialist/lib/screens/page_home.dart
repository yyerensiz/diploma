//front_specialist\lib\screens\page_home.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:shared_carenest/config.dart';
import '../models/model_order.dart';
import '../services/service_order.dart';
import 'page_child_detail.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Order> orders = [];
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
    final resp = await http.get(
      Uri.parse(URL_SPECIALIST_PROFILE),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      specialistId = data['id'] ?? data['specialist_id'];
      orders = await OrderService().fetchSpecialistOrders(specialistId!);
    }
    setState(() => isLoading = false);
  }

  Future<void> _updateOrderStatus(int id, String status) async {
    await OrderService().updateOrderStatus(id, status);
    if (specialistId != null) await _loadSpecialistIdAndOrders();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (orders.isEmpty) return Center(child: Text('no_current_orders'.tr()));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final o = orders[index];
        final date = o.scheduledFor.toLocal().toString().split('.')[0];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              o.serviceType,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('status_${o.status}'.tr()),
                Text(date),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('description_label'.tr(args: [o.description])),
                    const SizedBox(height: 8),
                    Text('cost_label'.tr(args: ['${o.totalCost}'])),
                    if (o.children != null && o.children!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'children_label'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: o.children!.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, j) {
                            final c = o.children![j];
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ChildDetailPage(child: c),
                                ),
                              ),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(
                                      c.pfpUrl ??
                                          'https://via.placeholder.com/50',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      c.name,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (o.status == 'pending') ...[
                          TextButton(
                            onPressed: () =>
                                _updateOrderStatus(o.id!, 'accepted'),
                            child: Text('accept'.tr()),
                          ),
                          TextButton(
                            onPressed: () =>
                                _updateOrderStatus(o.id!, 'cancelled'),
                            child: Text('reject'.tr()),
                          ),
                        ] else if (o.status == 'in_progress')
                          TextButton(
                            onPressed: () =>
                                _updateOrderStatus(o.id!, 'completed'),
                            child: Text('complete'.tr()),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
