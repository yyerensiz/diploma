//front_client\lib\core\providers\auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/model_user.dart';

class AuthProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;
  String? _token;

  UserProfile? get userProfile => _userProfile;
  bool get isAuthenticated => _userProfile != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _error;
  String? get jwtToken => _token;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final savedToken = await AuthService.getToken();
    if (savedToken != null) {
      _token = savedToken;
      await refreshProfile();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final firebaseToken = await credential.user!.getIdToken();
      if (firebaseToken == null) throw Exception('No token returned');
      await AuthService.saveToken(firebaseToken);
      _token = firebaseToken;
      await refreshProfile();
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await FirebaseAuth.instance.signOut();
      await AuthService.clear();
      _token = null;
      _userProfile = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    if (_token == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final profile = await AuthService.fetchMe(_token!);
      _userProfile = profile;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
