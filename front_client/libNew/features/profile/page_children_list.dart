//front_client\lib\features\profile\page_children_list.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:front_client/core/providers/provider_children.dart';
import 'package:front_client/features/profile/page_edit_profile_child.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/placeholder_empty.dart';
import '../../core/widgets/card_child.dart';
import 'page_add_child.dart';

class PageChildrenList extends StatefulWidget {
  const PageChildrenList({Key? key}) : super(key: key);

  @override
  _PageChildrenListState createState() => _PageChildrenListState();
}

class _PageChildrenListState extends State<PageChildrenList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChildrenProvider>().fetchChildren();
    });
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
    final childrenProv = context.watch<ChildrenProvider>();
    final children = childrenProv.children;
    final isLoading = childrenProv.isLoading;
    final error = childrenProv.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: Text('my_children'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PageAddChild()),
            ).then((_) => context.read<ChildrenProvider>().fetchChildren()),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: LoadingIndicator())
          : error != null
              ? Center(child: Text(error))
              : children.isEmpty
                  ? Center(child: PlaceholderEmpty(message: 'no_children_found'.tr()))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: children.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final c = children[idx];
                        return GestureDetector(
                          onTap: () async {
                            final ok = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditProfileChildPage(child: c),
                              ),
                            );
                            if (ok == true) {
                              context.read<ChildrenProvider>().fetchChildren();
                            }
                          },
                          child: CardChild(
                            name: c.name,
                            age: _calculateAge(c.dateOfBirth),
                            imageUrl: c.pfpUrl ?? '',
                          ),
                        );
                      },
                    ),
    );
  }
}
