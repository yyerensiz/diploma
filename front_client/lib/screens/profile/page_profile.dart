//front_client\lib\screens\profile\page_profile.dart
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:front_client/models/model_subsidy.dart';
import 'package:front_client/services/service_payments.dart';
import 'package:http/http.dart' as http;
import 'package:shared_carenest/config.dart';
import 'package:front_client/services/service_child.dart';
import '../../models/model_user.dart';
import '../../models/model_child.dart';
import 'page_children_add.dart';
import 'edit_profile.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _user;
  bool _loadingProfile = true;
  List<Child> _children = [];
  bool _loadingChildren = true;
  late Future<double>    _balanceFuture;
  late Future<Subsidy?>  _subsidyFuture;
  final _paymentSvc = PaymentService();

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _loadChildren();
    _balanceFuture = _paymentSvc.getBalance();
    _subsidyFuture = _paymentSvc.getSubsidy();
  }

  Future<void> _fetchUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      final res = await http.get(
        Uri.parse(URL_AUTH_ME),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _user = UserProfile.fromJson(data['user']);
          _loadingProfile = false;
        });
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (_) {
      setState(() => _loadingProfile = false);
    }
  }

  Future<void> _loadChildren() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    if (token != null) {
      final list = await ChildService().fetchChildren(token);
      setState(() {
        _children = list;
        _loadingChildren = false;
      });
    }
  }

  String _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return '$age ${'years_suffix'.tr()}';
  }

  @override
  Widget build(BuildContext context) {
    return _loadingProfile
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                

                // Profile Info Card
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              NetworkImage(_user?.profileImageUrl ?? ''),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _user?.fullName ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text('label_email'
                                  .tr(args: [_user?.email ?? ''])),
                              const SizedBox(height: 4),
                              Text('${'label_phone'.tr()}: ${_user!.phone ?? ''}'),
                              Text('${'label_address'.tr()}: ${_user!.address ?? ''}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Actions Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: Text('button_edit_profile'.tr()),
                        onPressed: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditProfilePage(user: _user!),
                            ),
                          );
                          if (updated == true) _fetchUser();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.child_care),
                        label: Text('add_child_button'.tr()),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PageChildrenAdd(),
                            ),
                          ).then((_) => _loadChildren());
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Children Section
                Text(
                  'my_children'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: _loadingChildren
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _children.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, idx) {
                          final c = _children[idx];
                          return GestureDetector(
                            onTap: () async {
                              final ok = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditChildPage(child: c),
                                ),
                              );
                              if (ok == true) _loadChildren();
                            },
                            // ← use your ChildCard here instead of a raw Column:
                            child: ChildCard(
                              name: c.name,
                              age: _calculateAge(c.dateOfBirth),
                              imageUrl: c.pfpUrl ?? '',
                            ),
                          );
                        },
                      ),
                ),


                const SizedBox(height: 48),
                FutureBuilder<double>(
                  future: _balanceFuture,
                  builder: (ctx, snap) {
                    if (snap.connectionState != ConnectionState.done)
                      return const Center(child: CircularProgressIndicator());
                    if (snap.hasError)
                      return Text('error_loading_balance'.tr(args: [snap.error.toString()]));

                    final bal = snap.data ?? 0.0;

                    // Wrap the Card in GestureDetector so tapping it opens the replenishment dialog
                    return GestureDetector(
                      onTap: () => _showReplenishDialog(context),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(Icons.account_balance_wallet),
                          title: Text('wallet_balance'.tr()),
                          trailing: Text('${bal.toStringAsFixed(2)} ₸'),
                        ),
                      ),
                    );
                  },
                ),
                  const SizedBox(height: 16),

                  FutureBuilder<Subsidy?>(
                    future: _subsidyFuture,
                    builder: (ctx, snap) {
                      if (snap.connectionState != ConnectionState.done)
                        return const Center(child: CircularProgressIndicator());
                      // on any error or inactive:
                      if (snap.hasError || snap.data == null || !snap.data!.active) {
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.request_page),
                            title: Text('subsidy_not_applied'.tr()),
                            subtitle: Text('subsidy_send_docs'.tr()),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                final result = await FilePicker.platform.pickFiles(type: FileType.any);
                                if (result == null) return;
                                final file = File(result.files.single.path!);
                                await _paymentSvc.applySubsidy(file);
                                setState(() {
                                  _subsidyFuture = _paymentSvc.getSubsidy();
                                });
                              },
                              child: Text('apply_subsidy'.tr()),
                            ),
                          ),
                        );
                      }
                      // if active subsidy:
                      final sub = snap.data!;
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.percent),
                          title: Text('subsidy_percent'.tr(args: [(sub.percentage * 100).toStringAsFixed(0)])),
                          subtitle: Text('subsidy_active'.tr()),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
          
  }
  Future<void> _showReplenishDialog(BuildContext context) async {
  final _cardNumberCtl = TextEditingController();
  final _expDateCtl    = TextEditingController();
  final _cvvCtl        = TextEditingController();
  final _amountCtl     = TextEditingController();

  bool _isLoading = false;
  String? _errorMsg;

  // We use StatefulBuilder so we can setState() inside the dialog
  await showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (BuildContext dialogCtx, StateSetter setDialogState) {
          return AlertDialog(
            title: Text('replenish_wallet'.tr()),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _cardNumberCtl,
                    decoration: InputDecoration(
                      labelText: 'card_number'.tr(), // Add a translation key
                      hintText: '1234123412341234',
                      errorText: (_errorMsg != null && _errorMsg!.contains('card_number'))
                          ? _errorMsg
                          : null,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _expDateCtl,
                    decoration: InputDecoration(
                      labelText: 'exp_date'.tr(), // e.g. “MM/YY”
                      hintText: 'MM/YY',
                      errorText: (_errorMsg != null && _errorMsg!.contains('exp_date'))
                          ? _errorMsg
                          : null,
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _cvvCtl,
                    decoration: InputDecoration(
                      labelText: 'cvv'.tr(),
                      hintText: '123',
                      errorText: (_errorMsg != null && _errorMsg!.contains('cvv'))
                          ? _errorMsg
                          : null,
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountCtl,
                    decoration: InputDecoration(
                      labelText: 'amount'.tr(), // e.g. “Amount to add”
                      hintText: '1000.00',
                      errorText: (_errorMsg != null && _errorMsg!.contains('amount'))
                          ? _errorMsg
                          : null,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  if (_errorMsg != null && !_errorMsg!.contains(RegExp(r'card_number|exp_date|cvv|amount')))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _errorMsg!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              if (_isLoading) const CircularProgressIndicator(),
              if (!_isLoading) ...[
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop(); // Cancel
                  },
                  child: Text('button_cancel'.tr()),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final cardNumber = _cardNumberCtl.text.trim();
                    final expDate    = _expDateCtl.text.trim();
                    final cvv        = _cvvCtl.text.trim();
                    final amountText = _amountCtl.text.trim();

                    // Basic local validation
                    if (cardNumber.length != 16 ||
                        int.tryParse(cardNumber) == null) {
                      setDialogState(() {
                        _errorMsg = 'invalid_card_number'.tr();
                      });
                      return;
                    }
                    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(expDate)) {
                      setDialogState(() {
                        _errorMsg = 'invalid_exp_date'.tr();
                      });
                      return;
                    }
                    if (cvv.length != 3 || int.tryParse(cvv) == null) {
                      setDialogState(() {
                        _errorMsg = 'invalid_cvv'.tr();
                      });
                      return;
                    }
                    final amt = double.tryParse(amountText);
                    if (amt == null || amt <= 0) {
                      setDialogState(() {
                        _errorMsg = 'invalid_amount'.tr();
                      });
                      return;
                    }

                    setDialogState(() {
                      _errorMsg = null;
                      _isLoading = true;
                    });

                    try {
                      final newBal = await _paymentSvc.replenishWallet(
                        cardNumber: cardNumber,
                        expDate: expDate,
                        cvv: cvv,
                        amount: amt,
                      );

                      // On success: close dialog and refresh balance
                      Navigator.of(dialogCtx).pop();
                      setState(() {
                        _balanceFuture = Future.value(newBal);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'replenish_success'
                              .tr(args: [newBal.toStringAsFixed(2)]),
                          ),
                        ),
                      );
                    } catch (e) {
                      setDialogState(() {
                        _errorMsg = e.toString().replaceFirst('Exception: ', '');
                        _isLoading = false;
                      });
                    }
                  },
                  child: Text('button_submit'.tr()),
                ),
              ]
            ],
          );
        },
      );
    },
  );
}
}


class ChildCard extends StatelessWidget {
  final String name;
  final String age;
  final String imageUrl;

  const ChildCard({
    required this.name,
    required this.age,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 30, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(height: 8),
          Text(name, style: Theme.of(context).textTheme.titleSmall),
          Text(age, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class ProfileMenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class EditChildPage extends StatefulWidget {
  final Child child;
  const EditChildPage({Key? key, required this.child}) : super(key: key);

  @override
  _EditChildPageState createState() => _EditChildPageState();
}

class _EditChildPageState extends State<EditChildPage> {
  late TextEditingController _nameCtl;
  late TextEditingController _bioCtl;
  late TextEditingController _pfpCtl;
  late DateTime _dob;

  @override
  void initState() {
    super.initState();
    _nameCtl = TextEditingController(text: widget.child.name);
    _bioCtl  = TextEditingController(text: widget.child.bio ?? '');
    _pfpCtl  = TextEditingController(text: widget.child.pfpUrl ?? '');
    _dob     = widget.child.dateOfBirth;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _updateChild() async {
    final user  = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    if (token == null) {
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('token_missing_error'.tr())));
      return;
    }

    final updatedChild = Child(
      id: widget.child.id,
      name:        _nameCtl.text,
      dateOfBirth: _dob,
      bio:         _bioCtl.text,
      pfpUrl:      _pfpCtl.text,
    );

    try {
      await ChildService().updateChild(token, widget.child.id, updatedChild);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_update_child'.tr(args: [e.toString()]))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dobStr = DateFormat.yMd(context.locale.toString()).format(_dob);
    return Scaffold(
      appBar: AppBar(title: Text('edit_child_title'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
            ElevatedButton(
              onPressed: _updateChild,
              child: Text('button_save'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}