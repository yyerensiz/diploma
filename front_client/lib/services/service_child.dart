import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/model_child.dart';
import 'auth_service.dart'; // for token

class ChildService {
  final String baseUrl = 'http://192.168.0.230:5000/api/children';
  

  Future<List<Child>> fetchChildren(String token) async {
    final String myChildrenUrl = '$baseUrl/my';
    final response = await http.get(
      
      Uri.parse(myChildrenUrl),  // GET /my for list
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['children'];
      return data.map((json) => Child.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load children');
    }
  }

  Future<void> deleteChild(String token, int childId) async {
    await http.delete(
      Uri.parse('$baseUrl/$childId'), // DELETE /:id without /my
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> createChild(String token, Child child) async {
    await http.post(
      Uri.parse(baseUrl), // POST /children (no /my)
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(child.toJson()),
    );
  }

  Future<void> updateChild(String token, int childId, Child updatedChild) async {
    await http.put(
      Uri.parse('$baseUrl/$childId'), // PUT /:id (no /my)
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedChild.toJson()),
      
    );
    print('Sending update request: $updatedChild');
    

  }
}
