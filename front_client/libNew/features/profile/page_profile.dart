//front_client\lib\features\profile\page_profile.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:front_client/core/providers/provider_children.dart';
import 'package:front_client/core/providers/provider_payment.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';

import '../../core/models/model_child.dart';
import '../../core/models/model_subsidy.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/placeholder_empty.dart';
import 'page_add_child.dart';
import 'page_edit_profile.dart';
import 'page_edit_profile_child.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    final authProv = context.read<AuthProvider>();
    authProv.refreshProfile();
    context.read<ChildrenProvider>().fetchChildren();
    context.read<PaymentProvider>().loadBalance();
    context.read<PaymentProvider>().loadSubsidy();
  }

  String _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return '$age ${'years_suffix'.tr()}';
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final childrenProv = context.watch<ChildrenProvider>();
    final paymentProv = context.watch<PaymentProvider>();

    final user = authProv.userProfile;
    final children = childrenProv.children;
    final isLoadingChildren = childrenProv.isLoading;
    final balance = paymentProv.balance;
    final subsidy = paymentProv.subsidy;
    final isLoadingBalance = paymentProv.isLoadingBalance;
    final isLoadingSubsidy = paymentProv.isLoadingSubsidy;

    return user == null
        ? const Center(child: LoadingIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              NetworkImage(user.profileImageUrl),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text('label_email'
                                  .tr(args: [user.email])),
                              const SizedBox(height: 4),
                              Text(
                                  '${'label_phone'.tr()}: ${user.phone}'),
                              Text(
                                  '${'label_address'.tr()}: ${user.address}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                                  EditProfilePage(user: user),
                            ),
                          );
                          if (updated == true) {
                            authProv.refreshProfile();
                          }
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
                              builder: (_) => PageAddChild(),
                            ),
                          ).then((_) =>
                              context.read<ChildrenProvider>().fetchChildren());
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'my_children'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: isLoadingChildren
                      ? const Center(child: LoadingIndicator())
                      : children.isEmpty
                          ? Center(
                              child: PlaceholderEmpty(
                                  message: 'no_children_found'.tr()),
                            )
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: children.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, idx) {
                                final c = children[idx];
                                return GestureDetector(
                                  onTap: () async {
                                    final ok = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditProfileChildPage(
                                                child: c),
                                      ),
                                    );
                                    if (ok == true) {
                                      context
                                          .read<ChildrenProvider>()
                                          .fetchChildren();
                                    }
                                  },
                                  child: _ChildCard(
                                    name: c.name,
                                    age: _calculateAge(c.dateOfBirth),
                                    imageUrl: c.pfpUrl ?? '',
                                  ),
                                );
                              },
                            ),
                ),
                const SizedBox(height: 48),
                isLoadingBalance
                    ? const Center(child: LoadingIndicator())
                    : Card(
                        child: ListTile(
                          leading: const Icon(Icons.account_balance_wallet),
                          title: Text('wallet_balance'.tr()),
                          trailing:
                              Text('${balance.toStringAsFixed(2)} ₸'),
                        ),
                      ),
                const SizedBox(height: 16),
                isLoadingSubsidy
                    ? const Center(child: LoadingIndicator())
                    : ((subsidy == null || !subsidy.active)
                        ? Card(
                            child: ListTile(
                              leading: const Icon(Icons.request_page),
                              title:
                                  Text('subsidy_not_applied'.tr()),
                              subtitle:
                                  Text('subsidy_send_docs'.tr()),
                              trailing: ElevatedButton(
                                onPressed: () async {
                                  final result =
                                      await FilePicker.platform
                                          .pickFiles(
                                              type: FileType.any);
                                  if (result == null) return;
                                  final file = File(
                                      result.files.single.path!);
                                  await paymentProv
                                      .applySubsidy(file);
                                  context
                                      .read<PaymentProvider>()
                                      .loadSubsidy();
                                },
                                child: Text('apply_subsidy'.tr()),
                              ),
                            ),
                          )
                        : Card(
                            child: ListTile(
                              leading: const Icon(Icons.percent),
                              title: Text(
                                  'subsidy_percent'
                                      .tr(args: [
                                        (subsidy.percentage * 100)
                                            .toStringAsFixed(0)
                                      ]),
                              ),
                              subtitle: Text('subsidy_active'.tr()),
                            ),
                          )),
              ],
            ),
          );
  }
}

class _ChildCard extends StatelessWidget {
  final String name;
  final String age;
  final String imageUrl;

  const _ChildCard({
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
