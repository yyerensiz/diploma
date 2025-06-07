//front_client\lib\features\orders\list_foldable_order.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/models/model_order.dart';
import '../../core/widgets/card_child.dart';
import '../../features/home/page_review_form.dart';

class ListFoldableOrder extends StatefulWidget {
  final List<Order> orders;
  final Future<void> Function(int orderId, String newStatus) onStatusChange;
  final String Function(DateTime) formatDate;
  final Future<void> Function() reload;

  const ListFoldableOrder({
    Key? key,
    required this.orders,
    required this.onStatusChange,
    required this.formatDate,
    required this.reload,
  }) : super(key: key);

  @override
  State<ListFoldableOrder> createState() => _ListFoldableOrderState();
}

class _ListFoldableOrderState extends State<ListFoldableOrder> {
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
          _expanded[index] = !isOpen;
        });
      },
      animationDuration: const Duration(milliseconds: 300),
      elevation: 2,
      children: widget.orders.asMap().entries.map((entry) {
        final idx = entry.key;
        final order = entry.value;

        return ExpansionPanel(
          isExpanded: _expanded[idx],
          canTapOnHeader: true,
          headerBuilder: (_, __) => ListTile(
            title: Text(
              order.serviceType,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.formatDate(order.scheduledFor)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'specialist_label'
                      .tr(args: [order.specialistName ?? '-']),
                ),
                const SizedBox(height: 8),
                Text('description_label'.tr(args: [order.description])),
                const SizedBox(height: 8),
                Text('cost_label'.tr(args: ['${order.totalCost}'])),
                if (order.children != null && order.children!.isNotEmpty) ...[
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
                      itemCount: order.children!.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, j) {
                        final kid = order.children![j];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewFormPage(
                                orderId: order.id!,
                                specialistId: order.specialistId!,
                              ),
                            ),
                          ),
                          child: CardChild(
                            name: kid.name,
                            age: '', // Age not displayed here
                            imageUrl: kid.pfpUrl ?? '',
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 12),
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
                              orderId: order.id!,
                              specialistId: order.specialistId!,
                            ),
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
