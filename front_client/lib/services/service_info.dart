import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/model_info.dart';

class InfoPanelService {
  final String baseUrl = 'http://192.168.0.230:5000/api/info-panels';

  Future<List<InfoPanelModel>> fetchInfoPanels() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['panels'] as List)
          .map((item) => InfoPanelModel.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load info panels');
    }
  }
}
