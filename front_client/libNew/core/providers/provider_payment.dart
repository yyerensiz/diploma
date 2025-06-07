//front_client\lib\core\providers\provider_payment.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/service_payment.dart';
import '../models/model_subsidy.dart';
import '../services/auth_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  double _balance = 0.0;
  Subsidy? _subsidy;
  bool _isLoadingBalance = false;
  bool _isLoadingSubsidy = false;
  String? _errorMessage;

  double get balance => _balance;
  Subsidy? get subsidy => _subsidy;
  bool get isLoadingBalance => _isLoadingBalance;
  bool get isLoadingSubsidy => _isLoadingSubsidy;
  String? get errorMessage => _errorMessage;

  Future<void> loadBalance() async {
    _isLoadingBalance = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');
      _balance = await _paymentService.getBalanceWithToken(token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingBalance = false;
      notifyListeners();
    }
  }

  Future<void> loadSubsidy() async {
    _isLoadingSubsidy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');
      _subsidy = await _paymentService.getSubsidyWithToken(token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingSubsidy = false;
      notifyListeners();
    }
  }

  Future<void> applySubsidy(File document) async {
    _isLoadingSubsidy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');
      await _paymentService.applySubsidyWithToken(token, document);
      await loadSubsidy();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoadingSubsidy = false;
      notifyListeners();
    }
  }
}
