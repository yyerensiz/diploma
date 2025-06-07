//front_client\lib\core\services\service_child.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/model_child.dart';

class ChildService {
  final Uri _childrenUrl = Uri.parse(URL_CHILDREN);
  final Uri _myChildrenUrl = Uri.parse(URL_CHILDREN_MY);

  Future<List<Child>> fetchChildren(String token) async {
    final resp = await http.get(
      _myChildrenUrl,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body)['children'] as List<dynamic>;
      return data.map((e) => Child.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch children (${resp.statusCode})');
  }

  Future<void> createChild(String token, Child child) async {
    final resp = await http.post(
      _childrenUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(child.toJson()),
    );
    if (resp.statusCode != 201) {
      throw Exception('Failed to create child (${resp.statusCode})');
    }
  }

  Future<void> updateChild(String token, int childId, Child updatedChild) async {
    final uri = Uri.parse('$URL_CHILDREN/$childId');
    final resp = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(updatedChild.toJson()),
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to update child (${resp.statusCode})');
    }
  }

  Future<void> deleteChild(String token, int childId) async {
    final uri = Uri.parse('$URL_CHILDREN/$childId');
    final resp = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to delete child (${resp.statusCode})');
    }
  }
}
