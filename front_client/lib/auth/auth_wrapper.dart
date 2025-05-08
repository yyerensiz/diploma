import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/navbar.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

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
      final userData = jsonDecode(response.body);
      return userData['role'];
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
        if (user == null) return LoginScreen();

        return FutureBuilder<String?>(
          future: _fetchUserRole(user),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }

            if (roleSnapshot.hasError || roleSnapshot.data != 'client') {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Недопустимая роль: только клиенты могут войти в это приложение."),
                    backgroundColor: Colors.red,
                  ),
                );

                final userProvider = Provider.of<UserProvider>(context, listen: false);
                await userProvider.signOut();
                userProvider.clearUserData();
              });

              return const LoadingScreen(); // Пока выходим — грузим
            }



            return MainScreen();
          },
        );
      },
    );
  }
}


class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
