import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_carenest/auth/login.dart'; // Import the shared LoginScreen
import 'package:shared_carenest/auth/signup.dart';
import 'package:shared_carenest/providers/user_provider.dart'; // Import the shared UserProvider

class AuthWrapper extends StatelessWidget {
  final String expectedRole;
  final Widget mainScreen;
  final String unauthorizedMessage;
  final String appName;
  final String tagline;

  const AuthWrapper({
    Key? key,
    required this.expectedRole,
    required this.mainScreen,
    required this.unauthorizedMessage,
    required this.appName,
    required this.tagline,
  }) : super(key: key);

  Future<String?> _fetchUserRole(User user) async {
    final idToken = await user.getIdToken();
    final response = await http.get(
      Uri.parse('http://192.168.0.230:5000/api/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      print('--- Full Response Body ---'); // Added logging
      print(response.body); // Log the entire response body
      final userData = jsonDecode(response.body);
      return userData['user']['role'];
    } else {
      return null;
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        final user = snapshot.data;
        // Wrap LoginScreen in a Builder to get the correct context.
        if (user == null) {
          return Builder(
            builder: (context) {
              return LoginScreen(
                appName: appName,
                tagline: tagline,
                signupScreen: SignupScreen(role: expectedRole),
              );
            },
          );
        }

        return FutureBuilder<String?>(
        future: _fetchUserRole(user),
        builder: (context, roleSnapshot) {
          if (roleSnapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          }

          print('--- AuthWrapper Role Check ---'); // Added logging

          if (roleSnapshot.hasError || roleSnapshot.data != expectedRole) {
            print('Expected Role: $expectedRole');
            if (roleSnapshot.hasData) {
              print('Fetched Role: "${roleSnapshot.data}"');
              print('Role Match: ${roleSnapshot.data == expectedRole}');
            }
            if (roleSnapshot.hasError) {
              print('Error fetching role: ${roleSnapshot.error}');
            }

            WidgetsBinding.instance.addPostFrameCallback((_) async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(unauthorizedMessage),
                  backgroundColor: Colors.red,
                ),
              );

              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              await userProvider.signOut();
              userProvider.clearUserData();
            });

            return const LoadingScreen();
          }

          return mainScreen;
        },
      );
        
      },
    );
    
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
