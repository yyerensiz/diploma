import 'package:flutter/foundation.dart';
import 'package:front_client/models/model_child.dart'; // Import your Child model
import 'package:front_client/services/service_child.dart'; // Import your ChildService
import 'package:firebase_auth/firebase_auth.dart'; // For getting the token

class ChildrenProvider with ChangeNotifier {
  List<Child> _children = [];
  final ChildService _childService = ChildService();
  bool _isLoading = false; // Add a loading state

  bool get isLoading => _isLoading;
  List<Child> get children => _children;

  Future<void> fetchChildren() async {
    _isLoading = true;
    notifyListeners(); // Notify listeners that loading has started
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User is not logged in');
        _children = [];
        _isLoading = false;
        notifyListeners();
        return;
      }
      final token = await user.getIdToken();
      _children = await _childService.fetchChildren(token!);
      _isLoading = false;
      notifyListeners(); // Notify listeners that loading is complete
    } catch (error) {
      print('Error fetching children: $error');
      _children = [];
      _isLoading = false;
      notifyListeners();
      // Consider showing an error message to the user.
    }
  }

  // Method to set children.  Useful if you get children from another source and want to use the provider.
  void setChildren(List<Child> children) {
    _children = children;
    notifyListeners();
  }

  // Method to add a child.  Adds to the backend and updates the provider.
  Future<void> addChild(Child child) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User is not logged in');
        return;
      }
      final token = await user.getIdToken();
      await _childService.createChild(token!, child); // Await the API call
      _children.add(child); // Update the local list *after* successful API call
      notifyListeners();
    } catch (error) {
      print('Error adding child: $error');
      //  Consider showing a message to the user.
    }
  }

  // Method to remove a child.  Removes from the backend and updates the provider.
  Future<void> removeChild(int childId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User is not logged in');
        return;
      }
      final token = await user.getIdToken();
      await _childService.deleteChild(token!, childId); // Await the API call
      _children.removeWhere((child) => child.id == childId); // Remove from local list
      notifyListeners();
    } catch (error) {
      print('Error removing child: $error');
      // Consider showing error message
    }
  }

  //Method to update a child
    Future<void> updateChild(int childId, Child updatedChild) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User is not logged in');
        return;
      }
      final token = await user.getIdToken();
      await _childService.updateChild(token!, childId, updatedChild);
      // Update the child in the local list
      final index = _children.indexWhere((child) => child.id == childId);
      if (index != -1) {
        _children[index] = updatedChild;
        notifyListeners();
      }
    } catch (error) {
      print('Error updating child: $error');
      // Handle error
    }
  }
}

