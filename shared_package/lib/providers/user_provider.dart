//shared_package\lib\providers\user_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  Map<String, dynamic>? _userData;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  Map<String, dynamic>? get userData => _userData;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void setUserData(Map<String, dynamic>? data) {
    _userData = data;
    notifyListeners();
  }

  void clearUserData() {
    _user = null;
    _userData = null;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign In Error: ${e.message}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      _user = null;
      _userData = null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign Out Error: ${e.message}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint('Reset Password Error: ${e.message}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_user != null) {
        await _user!.updateDisplayName(displayName);
        await _user!.updatePhotoURL(photoURL);
        await _auth.currentUser?.reload();
        _user = _auth.currentUser;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Update Profile Error: ${e.message}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
