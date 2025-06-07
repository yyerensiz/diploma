//front_client\lib\features\profile\page_edit_profile_child.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:front_client/core/providers/provider_children.dart';
import 'package:provider/provider.dart';
import '../../core/models/model_child.dart';
import '../../core/widgets/loading_indicator.dart';

class EditProfileChildPage extends StatefulWidget {
  final Child child;
  const EditProfileChildPage({Key? key, required this.child}) : super(key: key);

  @override
  _EditProfileChildPageState createState() => _EditProfileChildPageState();
}

class _EditProfileChildPageState extends State<EditProfileChildPage> {
  late TextEditingController _nameCtl;
  late TextEditingController _bioCtl;
  late TextEditingController _pfpCtl;
  late DateTime _dob;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtl = TextEditingController(text: widget.child.name);
    _bioCtl = TextEditingController(text: widget.child.bio ?? '');
    _pfpCtl = TextEditingController(text: widget.child.pfpUrl ?? '');
    _dob = widget.child.dateOfBirth;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: context.locale,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _updateChild() async {
    setState(() => _isSaving = true);
    final updatedChild = Child(
      id: widget.child.id,
      name: _nameCtl.text.trim(),
      dateOfBirth: _dob,
      bio: _bioCtl.text.trim(),
      pfpUrl: _pfpCtl.text.trim(),
    );
    try {
      await context.read<ChildrenProvider>().updateChild(widget.child.id, updatedChild);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error_update_child'.tr(args: [e.toString()]))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _bioCtl.dispose();
    _pfpCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dobStr = DateFormat.yMd(context.locale.toString()).format(_dob);
    return Scaffold(
      appBar: AppBar(title: Text('edit_child_title'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtl,
              decoration: InputDecoration(labelText: 'label_child_name'.tr()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioCtl,
              maxLines: 3,
              decoration: InputDecoration(labelText: 'label_child_bio'.tr()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pfpCtl,
              decoration: InputDecoration(labelText: 'label_child_pfp'.tr()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Text('label_dob'.tr(args: [dobStr]))),
                TextButton(
                  onPressed: _selectDate,
                  child: Text('change'.tr()),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _isSaving
                ? const Center(child: LoadingIndicator())
                : ElevatedButton(
                    onPressed: _updateChild,
                    child: Text('button_save'.tr()),
                  ),
          ],
        ),
      ),
    );
  }
}
