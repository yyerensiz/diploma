//front_specialist\lib\providers\provider_specialist.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/model_specialist.dart';
import '../services/service_specialist.dart';

class SpecialistProvider extends ChangeNotifier {
  Specialist? profile;
  bool isLoading = false;
  String? lastError;

  Future<void> loadProfile() async {
    if (isLoading) return;
    isLoading = true;
    lastError = null;
    notifyListeners();

    try {
      profile = await SpecialistService.fetchProfile();
      print('SpecialistProvider → loaded profile: $profile');
    } catch (e, st) {
      print('SpecialistProvider.loadProfile error: $e\n$st');
      lastError = e.toString();
      profile = null;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(Specialist updated) async {
    await SpecialistService.updateProfile(updated);
    await loadProfile();
  }

  Future<void> uploadVerificationDocs(XFile idDoc, XFile certDoc) async {
    await SpecialistService.uploadVerificationDocs(idDoc, certDoc);
    // Optionally reload profile (if verification status changes)
    await loadProfile();
  }
}
