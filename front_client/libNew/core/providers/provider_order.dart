//front_client\lib\core\providers\provider_order.dart
import 'package:flutter/material.dart';
import '../services/service_order.dart';
import '../models/model_order.dart';
import '../services/auth_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');
      _orders = await _orderService.fetchClientOrders(token);
    } catch (e) {
      _orders = [];
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrder(Order order) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');
      final newOrder = await _orderService.createOrder(token, order);
      _orders.insert(0, newOrder);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');
      await _orderService.updateOrderStatus(token, orderId, newStatus);
      await loadOrders();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
