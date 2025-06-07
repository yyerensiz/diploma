//front_client\lib\core\providers\provider_children.dart
import 'package:flutter/material.dart';
import '../services/service_child.dart';
import '../models/model_child.dart';
import '../services/auth_service.dart';

class ChildrenProvider extends ChangeNotifier {
  final ChildService _childService = ChildService();
  List<Child> _children = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Child> get children => List.unmodifiable(_children);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchChildren() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');
      _children = await _childService.fetchChildren(token);
    } catch (e) {
      _children = [];
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addChild(Child child) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');
      await _childService.createChild(token, child);
      _children.add(child);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateChild(int childId, Child updatedChild) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');
      await _childService.updateChild(token, childId, updatedChild);
      final idx = _children.indexWhere((c) => c.id == childId);
      if (idx != -1) _children[idx] = updatedChild;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeChild(int childId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');
      await _childService.deleteChild(token, childId);
      _children.removeWhere((c) => c.id == childId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
