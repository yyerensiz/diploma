//front_client\lib\core\providers\provider_info.dart
import 'package:flutter/material.dart';
import '../services/service_info.dart';
import '../models/model_info.dart';

class InfoProvider extends ChangeNotifier {
  final InfoService _infoService = InfoService();
  List<InfoPanelModel> _panels = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<InfoPanelModel> get panels => List.unmodifiable(_panels);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchInfoPanels() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _panels = await _infoService.fetchInfoPanels();
    } catch (e) {
      _panels = [];
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
