//front_client\lib\core\services\service_info.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/model_info.dart';

class InfoService {
  Future<List<InfoPanelModel>> fetchInfoPanels() async {
    final uri = Uri.parse(URL_INFO_PANELS);
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final panels = body['panels'] as List<dynamic>? ?? [];
      return panels
          .map((e) => InfoPanelModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load info panels (${resp.statusCode})');
  }
}
