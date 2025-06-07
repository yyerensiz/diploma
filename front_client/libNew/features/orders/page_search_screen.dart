//front_client\lib\features\orders\page_search_screen.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:front_client/core/providers/provider_specialist.dart';
import 'package:provider/provider.dart';
import 'page_search.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpecialistProvider>().fetchSpecialists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final specialistProv = context.watch<SpecialistProvider>();

    if (specialistProv.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (specialistProv.errorMessage != null) {
      return Center(
        child: Text('error_loading_specialists'.tr(args: [specialistProv.errorMessage!])),
      );
    } else if (specialistProv.specialists.isEmpty) {
      return Center(child: Text('no_specialists_available'.tr()));
    }

    return SearchPage(specialists: specialistProv.specialists);
  }
}
