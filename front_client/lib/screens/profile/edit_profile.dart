//front_client\lib\screens\profile\edit_profile.dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_carenest/config.dart';
import 'package:front_client/services/auth_service.dart';
import 'package:http/http.dart' as http;
import '../../models/model_user.dart';

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
    _phoneCtl = TextEditingController(text: widget.user.phone ?? '');
    _addrCtl = TextEditingController(text: widget.user.address ?? '');
    _imgCtl = TextEditingController(text: widget.user.profileImageUrl ?? '');
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();

    //final token = await AuthService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('not_authorized'.tr())),
      );
      setState(() => _isSaving = false);
      return;
    }

    final body = jsonEncode({
      'full_name': _nameCtl.text,
      'phone': _phoneCtl.text,
      'address': _addrCtl.text,
      'pfp_url': _imgCtl.text,
    });

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
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'save_profile_error'.tr(args: [resp.statusCode.toString(), resp.body]),
          ),
        ),
      );
    }

    setState(() => _isSaving = false);
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
              decoration: InputDecoration(labelText: 'label_full_name'.tr()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtl,
              decoration: InputDecoration(labelText: 'label_phone'.tr()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addrCtl,
              decoration: InputDecoration(labelText: 'label_address'.tr()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _imgCtl,
              decoration: InputDecoration(labelText: 'label_profile_image_url'.tr()),
            ),
            const SizedBox(height: 24),
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveProfile,
                    child: Text('button_save_changes'.tr()),
                  ),
          ],
        ),
      ),
    );
  }
}