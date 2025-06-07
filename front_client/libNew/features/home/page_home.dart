//front_client\lib\features\home\page_home.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../core/providers/provider_info.dart';
import '../../core/providers/provider_order.dart';
import '../../core/widgets/placeholder_empty.dart';
import '../../core/widgets/loading_indicator.dart';
import '../home/widget_info_panel.dart';
import '../orders/list_foldable_order.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InfoProvider>().fetchInfoPanels();
      context.read<OrderProvider>().loadOrders();
    });
  }

  String _formatOrderDate(DateTime dt) {
    final d = dt.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    final monthName = _russianMonth(d.month);
    return '$day $monthName, $hour:$minute';
  }

  String _russianMonth(int m) {
    const names = [
      '',
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
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

  @override
  Widget build(BuildContext context) {
    final infoProv = context.watch<InfoProvider>();
    final orderProv = context.watch<OrderProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: infoProv.isLoading
                ? const Center(child: LoadingIndicator())
                : infoProv.errorMessage != null
                    ? Center(child: Text(infoProv.errorMessage!))
                    : infoProv.panels.isEmpty
                        ? Center(child: PlaceholderEmpty(message: 'no_info_panels'.tr()))
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: infoProv.panels.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemBuilder: (_, i) {
                              final p = infoProv.panels[i];
                              return InfoPanelWidget(
                                title: p.title,
                                description: p.description,
                                color: p.color,
                              );
                            },
                          ),
          ),
          const SizedBox(height: 32),
          Text(
            'current_orders'.tr(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (orderProv.isLoading)
            const Center(child: LoadingIndicator())
          else if (orderProv.errorMessage != null)
            Center(child: Text(orderProv.errorMessage!))
          else if (orderProv.orders.isEmpty)
            Center(child: PlaceholderEmpty(message: 'no_current_orders'.tr()))
          else
            ListFoldableOrder(
              orders: orderProv.orders,
              onStatusChange: (id, status) => orderProv.updateOrderStatus(id, status),
              formatDate: _formatOrderDate,
              reload: () => orderProv.loadOrders(),
            ),
        ],
      ),
    );
  }
}
