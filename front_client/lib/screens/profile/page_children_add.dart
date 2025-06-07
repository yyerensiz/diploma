//front_client\lib\screens\profile\page_children_add.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_carenest/config.dart';

class PageChildrenAdd extends StatefulWidget {
  const PageChildrenAdd({Key? key}) : super(key: key);

  @override
  State<PageChildrenAdd> createState() => _PageChildrenAddState();
}

class _PageChildrenAddState extends State<PageChildrenAdd> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _birthCtl = TextEditingController();
  final _bioCtl = TextEditingController();
  bool _isSaving = false;

  String _pad(int v) => v.toString().padLeft(2, '0');

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('not_authorized'.tr())),
      );
      setState(() => _isSaving = false);
      return;
    }
    final token = await user.getIdToken();

    final uri = Uri.parse(URL_CREATE_CHILD);
    final body = jsonEncode({
      'name': _nameCtl.text,
      'date_of_birth': _birthCtl.text,
      'bio': _bioCtl.text,
    });

    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('child_added_success'.tr())),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_create_child'.tr(args: [resp.body]))),
      );
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('add_child_title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtl,
                decoration: InputDecoration(labelText: 'label_child_name'.tr()),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'error_enter_child_name'.tr()
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _birthCtl,
                decoration:
                    InputDecoration(labelText: 'label_date_of_birth'.tr()),
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.now().subtract(const Duration(days: 365 * 5)),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    locale: context.locale,
                  );
                  if (picked != null) {
                    _birthCtl.text =
                        '${picked.year}-${_pad(picked.month)}-${_pad(picked.day)}';
                  }
                },
                validator: (v) => (v == null || v.isEmpty)
                    ? 'error_enter_date'.tr()
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioCtl,
                decoration:
                    InputDecoration(labelText: 'label_additional_info'.tr()),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'error_enter_info'.tr()
                    : null,
              ),
              const SizedBox(height: 24),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text('add_child_button'.tr()),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}