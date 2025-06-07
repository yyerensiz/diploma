//front_client\lib\features\auth\page_signup.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../../core/config.dart';
import '../../core/widgets/loading_indicator.dart';
import 'page_login.dart';

class SignupPage extends StatefulWidget {
  final String role;
  const SignupPage({Key? key, required this.role}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailCtl.text.trim(), password: _passCtl.text.trim());
      final user = userCredential.user;
      if (user == null) throw Exception('signup_failed'.tr());
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final body = {
        'email': _emailCtl.text.trim(),
        'password': _passCtl.text.trim(),
        'full_name': _fullNameCtl.text.trim(),
        'phone': _phoneCtl.text.trim(),
        'fcm_token': fcmToken,
        'role': widget.role,
      };
      final resp = await http.post(
        Uri.parse(URL_REGISTER),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (resp.statusCode != 200 && resp.statusCode != 201) {
        throw Exception('error_signup_backend'.tr(args: [resp.body]));
      }
      if (!mounted) return;
      Navigator.of(context).popUntil((r) => r.isFirst);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LoginPage(
            appName: 'app_title'.tr(),
            tagline: 'tagline'.tr(),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'email-already-in-use' => 'error_email_in_use'.tr(),
        'weak-password' => 'error_weak_password'.tr(),
        _ => 'error_occurred'.tr(args: [e.message ?? '']),
      };
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fullNameCtl.dispose();
    _phoneCtl.dispose();
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('signup_title'.tr())),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _fullNameCtl,
                  decoration: InputDecoration(
                    labelText: 'label_full_name'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v?.isEmpty ?? true) ? 'error_enter_full_name'.tr() : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneCtl,
                  decoration: InputDecoration(
                    labelText: 'label_phone'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v?.isEmpty ?? true) ? 'error_enter_phone'.tr() : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'label_email'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v?.isEmpty ?? true) ? 'error_enter_email'.tr() : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'label_password'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => (v?.length ?? 0) < 6
                      ? 'error_password_length'.tr()
                      : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: _isLoading
                      ? const LoadingIndicator()
                      : ElevatedButton(
                          onPressed: _signUp,
                          child: Text('button_register'.tr()),
                        ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => LoginPage(
                        appName: 'app_title'.tr(),
                        tagline: 'tagline'.tr(),
                      ),
                    ),
                  ),
                  child: Text('link_already_have_account'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
