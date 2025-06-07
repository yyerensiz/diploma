<<<<<<< HEAD
import 'package:flutter/foundation.dart';

class ChildrenProvider with ChangeNotifier {
  List<Map<String, dynamic>> _children = [
    {'id': '1', 'name': 'Qazyna', 'age': '7 years'},
    {'id': '2', 'name': 'Nurgeldi', 'age': '5 years'},
  ];

  List<Map<String, dynamic>> get children => _children;

  void setChildren(List<Map<String, dynamic>> children) {
    _children = children;
    notifyListeners();
  }

  void addChild(Map<String, dynamic> child) {
    _children.add(child);
    notifyListeners();
  }

  void removeChild(String id) {
    _children.removeWhere((child) => child['id'] == id);
    notifyListeners();
  }
} 
=======
//front_client\lib\providers\children_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:front_client/models/model_child.dart';
import 'package:front_client/services/service_child.dart';

class ChildrenProvider extends ChangeNotifier {
  final ChildService _childService = ChildService();
  List<Child> _children = [];
  bool _isLoading = false;
  String? _error;

  List<Child> get children => List.unmodifiable(_children);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  Future<void> fetchChildren() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not authenticated');
      _children = await _childService.fetchChildren(token);
    } catch (e) {
      debugPrint('Error fetching children: $e');
      _children = [];
      _error = 'error_loading_children'.tr();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addChild(Child child) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not authenticated');
      await _childService.createChild(token, child);
      _children.add(child);
    } catch (e) {
      debugPrint('Error adding child: $e');
      _error = 'error_adding_child'.tr();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateChild(int childId, Child updatedChild) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not authenticated');
      await _childService.updateChild(token, childId, updatedChild);
      final idx = _children.indexWhere((c) => c.id == childId);
      if (idx != -1) _children[idx] = updatedChild;
    } catch (e) {
      debugPrint('Error updating child: $e');
      _error = 'error_updating_child'.tr();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeChild(int childId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not authenticated');
      await _childService.deleteChild(token, childId);
      _children.removeWhere((c) => c.id == childId);
    } catch (e) {
      debugPrint('Error removing child: $e');
      _error = 'error_removing_child'.tr();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setChildren(List<Child> list) {
    _children = List.of(list);
    notifyListeners();
  }
}
>>>>>>> yrys1
