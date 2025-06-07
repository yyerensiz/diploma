// front_specialist/lib/screens/page_profile.dart
import 'package:flutter/material.dart';
import 'package:front_specialist/services/service_payments.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/model_specialist.dart';
import '../providers/provider_specialist.dart';

class SpecialistProfilePage extends StatefulWidget {
  const SpecialistProfilePage({Key? key}) : super(key: key);

  @override
  State<SpecialistProfilePage> createState() => _SpecialistProfilePageState();
}

class _SpecialistProfilePageState extends State<SpecialistProfilePage> {
  late Future<double> _balanceFuture;
  final _paymentSvc = PaymentService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpecialistProvider>().loadProfile();
    });
    _balanceFuture = _paymentSvc.getBalance();
  }

  void _showEditDialog(Specialist profile) {
    final nameCtl = TextEditingController(text: profile.fullName);
    final bioCtl = TextEditingController(text: profile.bio);
    final pfpCtl = TextEditingController(text: profile.pfpUrl);
    final rateCtl = TextEditingController(text: profile.hourlyRate?.toString());
    final timesCtl = TextEditingController(text: profile.availableTimes);
    final phoneCtl = TextEditingController(text: profile.phone);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('edit_profile_title'.tr()),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameCtl,
                decoration: InputDecoration(labelText: 'label_full_name'.tr()),
              ),
              TextField(
                controller: bioCtl,
                decoration: InputDecoration(labelText: 'label_bio'.tr()),
              ),
              TextField(
                controller: pfpCtl,
                decoration: InputDecoration(labelText: 'label_profile_image_url'.tr()),
              ),
              TextField(
                controller: rateCtl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'label_hourly_rate'.tr()),
              ),
              TextField(
                controller: timesCtl,
                decoration: InputDecoration(labelText: 'label_available_time'.tr()),
              ),
              TextField(
                controller: phoneCtl,
                decoration: InputDecoration(labelText: 'label_phone'.tr()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('button_save'.tr()),
            onPressed: () async {
              final updated = Specialist(
                id: profile.id,
                fullName: nameCtl.text,
                bio: bioCtl.text,
                pfpUrl: pfpCtl.text.isEmpty ? null : pfpCtl.text,
                hourlyRate: rateCtl.text.isEmpty ? null : double.tryParse(rateCtl.text),
                availableTimes: timesCtl.text,
                phone: phoneCtl.text,
                rating: profile.rating,
                verified: profile.verified,
                email: profile.email,
              );
              await context.read<SpecialistProvider>().updateProfile(updated);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('profile_updated'.tr())),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showVerificationDialog() {
    XFile? idDoc, certDoc;
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          title: Text('upload_documents'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() => idDoc = picked);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('id_uploaded'.tr())),
                    );
                  }
                },
                child: Text(idDoc != null ? 'id_uploaded'.tr() : 'upload_id'.tr()),
              ),
              ElevatedButton(
                onPressed: () async {
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() => certDoc = picked);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('certificate_uploaded'.tr())),
                    );
                  }
                },
                child: Text(certDoc != null ? 'certificate_uploaded'.tr() : 'upload_certificate'.tr()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (idDoc == null || certDoc == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('verification_documents_required'.tr())),
                  );
                  return;
                }
                await context.read<SpecialistProvider>().uploadVerificationDocs(idDoc!, certDoc!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('documents_sent'.tr())),
                );
              },
              child: Text('send'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReplenishDialog(BuildContext context) async {
    final _cardNumberCtl = TextEditingController();
    final _expDateCtl = TextEditingController();
    final _cvvCtl = TextEditingController();
    final _amountCtl = TextEditingController();

    bool _isLoading = false;
    String? _errorMsg;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
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
                        labelText: 'card_number'.tr(),
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
                        labelText: 'exp_date'.tr(),
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
                        labelText: 'amount'.tr(),
                        hintText: '1000.00',
                        errorText: (_errorMsg != null && _errorMsg!.contains('amount'))
                            ? _errorMsg
                            : null,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    if (_errorMsg != null &&
                        !_errorMsg!.contains(RegExp(r'card_number|exp_date|cvv|amount')))
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
                      Navigator.of(dialogCtx).pop();
                    },
                    child: Text('button_cancel'.tr()),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final cardNumber = _cardNumberCtl.text.trim();
                      final expDate = _expDateCtl.text.trim();
                      final cvv = _cvvCtl.text.trim();
                      final amountText = _amountCtl.text.trim();

                      if (cardNumber.length != 16 || int.tryParse(cardNumber) == null) {
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

                        Navigator.of(dialogCtx).pop();
                        setState(() {
                          _balanceFuture = Future.value(newBal);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'replenish_success'.tr(args: [newBal.toStringAsFixed(2)]),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<SpecialistProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.lastError != null) {
          return Center(
            child: Text('error_loading_profile'.tr(args: [provider.lastError!])),
          );
        }

        final profile = provider.profile!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: NetworkImage(profile.pfpUrl ?? ''),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.fullName ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.email, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    profile.email ?? '',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  profile.phone ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if ((profile.bio ?? '').isNotEmpty) ...[
                Text(
                  'about_specialist'.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.bio!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
              ],
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                child: Column(
                  children: [
                    if (profile.hourlyRate != null)
                      ListTile(
                        leading: const Icon(Icons.attach_money),
                        title: Text('hourly_rate'.tr(args: ['${profile.hourlyRate}'])),
                      ),
                    if ((profile.availableTimes ?? '').isNotEmpty)
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text('available_time'.tr(args: [profile.availableTimes!])),
                      ),
                    if (profile.rating != null)
                      ListTile(
                        leading: const Icon(Icons.star),
                        title: Text(
                            'rating'.tr(args: ['${profile.rating!.toStringAsFixed(1)}'])),
                      ),
                    ListTile(
                      leading: const Icon(
                        Icons.verified,
                        color: Colors.green,
                      ),
                      title: Text(
                        profile.verified == true
                            ? 'status_verified'.tr()
                            : 'status_not_verified'.tr(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditDialog(profile),
                      icon: const Icon(Icons.edit),
                      label: Text('edit_profile'.tr()),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  if (profile.verified != true) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showVerificationDialog,
                        icon: const Icon(Icons.upload_file),
                        label: Text('verification_prompt'.tr()),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 48),
              FutureBuilder<double>(
                future: _balanceFuture,
                builder: (ctx, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Text('error_loading_balance'.tr(args: [snap.error.toString()]));
                  }
                  final bal = snap.data ?? 0.0;
                  return GestureDetector(
                    onTap: () => _showReplenishDialog(context),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.account_balance_wallet),
                        title: Text('wallet_balance'.tr()),
                        trailing: Text('${bal.toStringAsFixed(2)} ₸'),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
