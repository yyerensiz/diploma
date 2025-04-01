import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/navbar.dart';
import 'login.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key}); // Added key parameter

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

        return Consumer<UserProvider>(
          builder: (_, userProvider, __) {
            if (userProvider.user == null) {
              userProvider.setUser(user);
            }
            return MainScreen(); // Ensuring this is a constant widget if possible
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
