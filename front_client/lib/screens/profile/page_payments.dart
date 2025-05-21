// front_client/lib/screens/common/page_payments.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../services/service_payments.dart';
import '../../models/model_subsidy.dart';

class PaymentPage extends StatefulWidget {
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Future<double> _balanceFuture;
  late Future<Subsidy?> _subsidyFuture;
  final _svc = PaymentService();

  @override
  void initState() {
    super.initState();
    _balanceFuture = _svc.getBalance();
    _subsidyFuture = _svc.getSubsidy();
  }

  Future<void> _pickAndApply() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null) return;
    final file = File(result.files.single.path!);
    try {
      await _svc.applySubsidy(file);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Заявка на субсидию отправлена')),
      );
      setState(() {
        _subsidyFuture = _svc.getSubsidy();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
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
            FutureBuilder<Subsidy?>(
              future: _subsidyFuture,
              builder: (ctx, snap) {
                switch (snap.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    return Center(child: CircularProgressIndicator());
                  case ConnectionState.done:
                  default:
                    if (snap.hasError) {
                      print('Error loading subsidy: ${snap.error}');
                      return _noSubsidyCard();
                    }
                    if (snap.hasData && snap.data != null && snap.data!.active) {
                      final sub = snap.data!;
                      if (sub.percentage > 0) {
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.percent),
                            title: Text(
                              'Субсидия: ${(sub.percentage * 100).toStringAsFixed(0)}%',
                            ),
                            subtitle: Text('Действует'),
                          ),
                        );
                      }
                    }
                    return _noSubsidyCard();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _noSubsidyCard() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.request_page),
        title: Text('Субсидия не оформлена'),
        subtitle: Text('Вы можете отправить документы'),
        trailing: ElevatedButton(
          onPressed: _pickAndApply,
          child: Text('Оформить'),
        ),
      ),
    );
  }
}
