//front_client\lib\core\providers\provider_specialist.dart
import 'package:flutter/material.dart';
import '../services/service_specialist.dart';
import '../models/model_specialist.dart';

class SpecialistProvider extends ChangeNotifier {
  final SpecialistService _specialistService = SpecialistService();
  List<Specialist> _specialists = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Specialist> get specialists => List.unmodifiable(_specialists);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSpecialists() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _specialists = await _specialistService.fetchSpecialists();
    } catch (e) {
      _specialists = [];
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
