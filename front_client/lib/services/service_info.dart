// front_client/lib/services/info_panel_service.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_carenest/config.dart';
import '../models/model_info.dart';

class InfoPanelService {
  Future<List<InfoPanelModel>> fetchInfoPanels() async {
    final uri = Uri.parse(URL_INFO_PANELS);
    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final panels = body['panels'] as List<dynamic>? ?? [];
        return panels
            .map((e) => InfoPanelModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint(
          'fetchInfoPanels failed [${resp.statusCode}]: ${resp.body}',
        );
        throw Exception(
          'Failed to load info panels (${resp.statusCode})',
        );
      }
    } catch (e, st) {
      debugPrint('Error fetching info panels: $e\n$st');
      rethrow;
    }
  }
}
