// front_client/lib/screens/common/page_payments.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/service_payments.dart';

class PaymentPage extends StatefulWidget {
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Future<double> _balanceFuture;
  final _svc = PaymentService();

  @override
  void initState() {
    super.initState();
    _balanceFuture = _svc.getBalance();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Платежные данные')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ───────── Wallet balance ─────────
            FutureBuilder<double>(
              future: _balanceFuture,
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Text('Ошибка загрузки баланса: ${snap.error}');
                }
                final balance = snap.data ?? 0.0;
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.account_balance_wallet),
                    title: Text('Баланс кошелька'),
                    trailing: Text('${balance.toStringAsFixed(2)} ₸'),
                  ),
                );
              },
            ),

            SizedBox(height: 24),

            // ───────── Subsidy status ─────────
            
          ],
        ),
      ),
    );
  }

}
