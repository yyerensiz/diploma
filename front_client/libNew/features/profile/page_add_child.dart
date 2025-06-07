//front_client\lib\features\profile\page_add_child.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:front_client/core/providers/provider_children.dart';
import 'package:provider/provider.dart';
import '../../core/models/model_child.dart';
import '../../core/widgets/loading_indicator.dart';

class PageAddChild extends StatefulWidget {
  const PageAddChild({Key? key}) : super(key: key);

  @override
  _PageAddChildState createState() => _PageAddChildState();
}

class _PageAddChildState extends State<PageAddChild> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _dobCtl = TextEditingController();
  final _bioCtl = TextEditingController();
  DateTime? _selectedDob;
  bool _isSaving = false;

  String _pad(int v) => v.toString().padLeft(2, '0');

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: context.locale,
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobCtl.text = '${picked.year}-${_pad(picked.month)}-${_pad(picked.day)}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDob == null) return;
    setState(() => _isSaving = true);
    try {
      final newChild = Child(
        id: 0,
        name: _nameCtl.text.trim(),
        dateOfBirth: _selectedDob!,
        bio: _bioCtl.text.trim(),
        pfpUrl: '',
      );
      await context.read<ChildrenProvider>().addChild(newChild);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error_create_child'.tr(args: [e.toString()]))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _dobCtl.dispose();
    _bioCtl.dispose();
    super.dispose();
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
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'error_enter_child_name'.tr() : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dobCtl,
                decoration: InputDecoration(labelText: 'label_date_of_birth'.tr()),
                readOnly: true,
                onTap: _pickDob,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'error_enter_date'.tr() : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioCtl,
                decoration: InputDecoration(labelText: 'label_additional_info'.tr()),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'error_enter_info'.tr() : null,
              ),
              const SizedBox(height: 24),
              _isSaving
                  ? const Center(child: LoadingIndicator())
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
