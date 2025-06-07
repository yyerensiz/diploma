//front_client\lib\screens\orders\page_search_screen.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:front_client/services/service_specialist.dart';
import 'package:front_client/models/model_specialist.dart';
import 'page_search.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<List<Specialist>> _futureSpecialists;

  @override
  void initState() {
    super.initState();
    _futureSpecialists = SpecialistService().fetchSpecialists();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Specialist>>(
      future: _futureSpecialists,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'error_loading_specialists'.tr(args: [snapshot.error.toString()]),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('no_specialists_available'.tr()),
          );
        }
        return SearchPage(specialists: snapshot.data!);
      },
    );
  }
}