// front_client\lib\screens\home\page_home.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:front_client/models/model_order.dart';
import 'package:front_client/screens/home/page_child_detail.dart';
import 'package:front_client/screens/home/page_review.dart';
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
  late String _token;
  final _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _infoPanelsFuture = InfoPanelService().fetchInfoPanels();
    FirebaseAuth.instance.currentUser?.getIdToken().then((t) {
      _token = t!;
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    if (_token.isEmpty) return;
    setState(() {
      _ordersFuture = _orderService.fetchClientOrders(_token);
    });
  }

  Future<void> _changeStatus(int orderId, String newStatus) async {
  await _orderService.updateOrderStatus(orderId, newStatus);
  await _loadOrders();
}


  Color _panelColor(String color) {
    switch (color) {
      case 'blue':
        return Colors.blue.shade100;
      case 'green':
        return Colors.green.shade100;
      case 'orange':
        return Colors.orange.shade100;
      case 'red':
        return Colors.red.shade100;
      case 'purple':
        return Colors.purple.shade100;
      case 'yellow':
        return Colors.yellow.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ───── Info Panels ─────
          SizedBox(
            height: 200,
            child: FutureBuilder<List<InfoPanelModel>>(
              future: _infoPanelsFuture,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Text('error loading info'.tr());
                }
                final panels = snap.data ?? [];
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: panels.length,
                  separatorBuilder: (_, __) => SizedBox(width: 16),
                  itemBuilder: (_, i) {
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
          SizedBox(height: 32),
          Text('current_orders'.tr(),
              style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 16),
          FutureBuilder<List<Order>>(
            future: _ordersFuture,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Text('error_loading_orders'.tr());
              }
              final orders = snap.data ?? [];
              if (orders.isEmpty) return Text('no_current_orders'.tr());

              return _FoldableOrderList(
                orders: orders,
                onStatusChange: _changeStatus,
                formatDate: _formatOrderDate,
                reload: _loadOrders,
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatOrderDate(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day} ${_russianMonth(d.month)}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _russianMonth(int m) {
    const names = [
      '',
      'января',
      'февраля',
      'марта',
      'апреля',
      'may',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря'
    ];
    return names[m];
  }
}

class _FoldableOrderList extends StatefulWidget {
  final List<Order> orders;
  final Future<void> Function(int orderId, String newStatus) onStatusChange;
  final String Function(DateTime) formatDate;
  final Future<void> Function() reload;

  const _FoldableOrderList({
    required this.orders,
    required this.onStatusChange,
    required this.formatDate,
    required this.reload,
  });

  @override
  State<_FoldableOrderList> createState() => _FoldableOrderListState();
}

class _FoldableOrderListState extends State<_FoldableOrderList> {
  late List<bool> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = List.generate(widget.orders.length, (_) => false);
  }

  String _statusText(String status) => 'status_$status'.tr();

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return Colors.indigo;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (index, isOpen) {
        setState(() {
          _expanded[index] = !_expanded[index];
        });
      },
      animationDuration: Duration(milliseconds: 300),
      elevation: 2,
      children: widget.orders.asMap().entries.map((entry) {
        final idx = entry.key;
        final order = entry.value;

        return ExpansionPanel(
          isExpanded: _expanded[idx],
          canTapOnHeader: true,
          headerBuilder: (_, __) => ListTile(
            title: Text(order.serviceType,
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.formatDate(order.scheduledFor)),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusText(order.status),
                    style: TextStyle(
                      fontSize: 12,
                      color: _statusColor(order.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('specialist_label'.tr(args: [order.specialistName ?? '-'])),
                SizedBox(height: 8),
                Text('description_label'.tr(args: [order.description])),
                SizedBox(height: 8),
                Text('cost_label'.tr(args: ['${order.totalCost}'])),

                if (order.children!.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text('children_label'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: order.children!.length,
    separatorBuilder: (_, __) => SizedBox(width: 12),
    itemBuilder: (_, j) {
      final kid = order.children?[j];
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChildDetailPage(child: kid!),
          ),
        ),
        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                  kid?.pfpUrl ?? 'https://via.placeholder.com/50',
                ),
                onBackgroundImageError: (_, __) {}, // Prevent crash on error
              ),
              SizedBox(height: 4),
              Text(
                kid!.name,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    },
  ),
                  ),
                ],

                SizedBox(height: 12),
                if (order.status == 'accepted') ...[
                  Center(
                    child: ElevatedButton(
                      onPressed: () =>
                          widget.onStatusChange(order.id!, 'in_progress'),
                      child: Text('start_work'.tr()),
                    ),
                  ),
                ] else if (order.status == 'completed') ...[
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final posted = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewFormPage(
                                orderId: order.id!, specialistId: order.specialistId!),
                          ),
                        );
                        if (posted == true) widget.reload();
                      },
                      child: Text('leave_review'.tr()),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class InfoPanel extends StatelessWidget {
  final String title, description;
  final Color color;

  const InfoPanel({
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext c) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 300,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(c).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
            SizedBox(height: 8),
            Text(description,
                style: Theme.of(c).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
