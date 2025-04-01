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