//front_client\lib\features\auth\auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:front_client/navbar.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart' as CoreAuth; // avoid collision
import 'page_login.dart';
import 'page_signup.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/loading_indicator.dart';

class ClientAuthWrapper extends StatefulWidget {
  const ClientAuthWrapper({Key? key}) : super(key: key);

  @override
  _ClientAuthWrapperState createState() => _ClientAuthWrapperState();
}

class _ClientAuthWrapperState extends State<ClientAuthWrapper> {
  bool _hasSignedOut = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: LoadingIndicator()));
        }
        final user = authSnap.data;
        if (user == null) {
          return LoginPage(
            appName: 'app_title'.tr(),
            tagline: 'tagline'.tr(),
            signupPage: const SignupPage(role: 'client'),
          );
        }
        return FutureBuilder<String?>(
          future: CoreAuth.AuthService.fetchUserRole(user),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: LoadingIndicator()));
            }
            final role = roleSnap.data;
            if (role != 'client') {
              if (!_hasSignedOut) {
                _hasSignedOut = true;
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('unauthorized_role'.tr()),
                      backgroundColor: Colors.red,
                    ),
                  );
                  await context.read<AuthProvider>().signOut();
                });
              }
              return LoginPage(
                appName: 'app_title'.tr(),
                tagline: 'tagline'.tr(),
                signupPage: const SignupPage(role: 'client'),
              );
            }
            return const MainScreen();
          },
        );
      },
    );
  }
}
