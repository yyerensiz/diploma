// front_client/lib/services/service_children.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_carenest/config.dart';
import '../models/model_child.dart';

class ChildService {
  final Uri _childrenUrl   = Uri.parse(URL_CHILDREN);
  final Uri _myChildrenUrl = Uri.parse(URL_CHILDREN_MY);

  Future<List<Child>> fetchChildren(String token) async {
    try {
      final resp = await http.get(
        _myChildrenUrl,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body)['children'] as List<dynamic>;
        return data
            .map((e) => Child.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      debugPrint('fetchChildren failed [${resp.statusCode}]: ${resp.body}');
      throw Exception('Failed to fetch children (${resp.statusCode})');
    } catch (e, st) {
      debugPrint('Error in fetchChildren: $e\n$st');
      rethrow;
    }
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
      debugPrint('createChild failed [${resp.statusCode}]: ${resp.body}');
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
      debugPrint('updateChild failed [${resp.statusCode}]: ${resp.body}');
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
      debugPrint('deleteChild failed [${resp.statusCode}]: ${resp.body}');
      throw Exception('Failed to delete child (${resp.statusCode})');
    }
  }
}
