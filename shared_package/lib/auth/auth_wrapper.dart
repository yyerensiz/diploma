// shared_package/lib/auth/auth_wrapper.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_carenest/services/auth_service.dart';
import '../config.dart';
import 'login.dart';
import 'signup.dart';
import 'package:shared_carenest/providers/user_provider.dart';
import 'package:shared_carenest/widgets/loading_indicator.dart';

class AuthWrapper extends StatefulWidget {
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

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService();
  bool _hasSignedOut = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting)
          return const Scaffold(body: Center(child: LoadingIndicator()));

        final user = authSnap.data;
        if (user == null) {
          // Not signed in → show login immediately
          return LoginScreen(
            appName: widget.appName,
            tagline: widget.tagline,
            signupScreen: SignupScreen(role: widget.expectedRole),
          );
        }

        // Signed in → check their role once
        return FutureBuilder<String?>(
          future: _authService.fetchUserRole(user),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting)
              return const Scaffold(body: Center(child: LoadingIndicator()));

            final role = roleSnap.data;
            if (role != widget.expectedRole) {
              // Only sign out once
              if (!_hasSignedOut) {
                _hasSignedOut = true;
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(widget.unauthorizedMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);
                  await userProvider.signOut();
                  userProvider.clearUserData();
                });
              }
              // Immediately return login screen instead of spinner
              return LoginScreen(
                appName: widget.appName,
                tagline: widget.tagline,
                signupScreen: SignupScreen(role: widget.expectedRole),
              );
            }

            // Role is good → main screen
            return widget.mainScreen;
          },
        );
      },
    );
  }
}
