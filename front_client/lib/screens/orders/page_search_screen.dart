import 'package:flutter/material.dart';
import 'package:front_client/services/service_specialist.dart';
import 'package:front_client/models/model_specialist.dart';
import 'page_search.dart'; // <-- Your SearchPage above

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
          return Center(child: Text('Error loading specialists: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No specialists available.'));
        }
        return SearchPage(specialists: snapshot.data!);
      },
    );
  }
}
