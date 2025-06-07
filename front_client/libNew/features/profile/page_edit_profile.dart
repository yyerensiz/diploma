//front_client\lib\features\profile\page_edit_profile.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/config.dart';
import '../../core/services/auth_service.dart';
import '../../core/providers/auth_provider.dart' as local_auth;
import '../../core/models/model_user.dart';
import '../../core/widgets/loading_indicator.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile user;
  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameCtl;
  late final TextEditingController _phoneCtl;
  late final TextEditingController _addrCtl;
  late final TextEditingController _imgCtl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtl = TextEditingController(text: widget.user.fullName);
    _phoneCtl = TextEditingController(text: widget.user.phone);
    _addrCtl = TextEditingController(text: widget.user.address);
    _imgCtl = TextEditingController(text: widget.user.profileImageUrl);
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('not_authorized'.tr())),
      );
      setState(() => _isSaving = false);
      return;
    }
    final body = jsonEncode({
      'full_name': _nameCtl.text.trim(),
      'phone': _phoneCtl.text.trim(),
      'address': _addrCtl.text.trim(),
      'pfp_url': _imgCtl.text.trim(),
    });
    try {
      final uid = await AuthService.getFirebaseUid();
      final uri = Uri.parse('$API_BASE/api/users/$uid');
      final resp = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      if (resp.statusCode == 200) {
        // refresh in provider
        await context.read<local_auth.AuthProvider>().refreshProfile();
        if (mounted) Navigator.of(context).pop(true);
      } else {
        throw Exception('${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('save_profile_error'.tr(args: [e.toString()])),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _addrCtl.dispose();
    _imgCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('edit_profile_title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameCtl,
              decoration:
                  InputDecoration(labelText: 'label_full_name'.tr()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtl,
              decoration: InputDecoration(labelText: 'label_phone'.tr()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addrCtl,
              decoration:
                  InputDecoration(labelText: 'label_address'.tr()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _imgCtl,
              decoration: InputDecoration(
                  labelText: 'label_profile_image_url'.tr()),
            ),
            const SizedBox(height: 24),
            _isSaving
                ? const Center(child: LoadingIndicator())
                : ElevatedButton(
                    onPressed: _saveProfile,
                    child:
                        Text('button_save_changes'.tr()),
                  ),
          ],
        ),
      ),
    );
  }
}
