import 'package:flutter/material.dart';
import 'package:front_client/screens/page_specialist_profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


// Модель специалиста
class Specialist {
  final String id;
  final String name;
  final double rating;
  final String imageUrl;
  final String description;

  Specialist({
    required this.id,
    required this.name,
    required this.rating,
    required this.imageUrl,
    required this.description,
  });

  factory Specialist.fromJson(Map<String, dynamic> json) {
    return Specialist(
      id: json['specialist_id'].toString(),  // updated to match the backend response
      name: json['full_name'],
      rating: (json['rating'] ?? 0).toDouble(),
      imageUrl: json['pfp_url'] ?? '',  // updated to match the backend response
      description: json['bio'] ?? '',
    );
  }
}



List<Specialist> parseSpecialists(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Specialist>((json) => Specialist.fromJson(json)).toList();
}

class SpecialistSelectionPage extends StatefulWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final List<String> selectedChildren;
  final String description;
  final String? serviceType;


  SpecialistSelectionPage({
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedChildren,
    required this.description,
    required this.serviceType,
  });

  @override
  _SpecialistSelectionPageState createState() =>
      _SpecialistSelectionPageState();
}

class _SpecialistSelectionPageState extends State<SpecialistSelectionPage> {
  List<Specialist> specialists = [];
  List<Specialist> filteredSpecialists = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSpecialists();
    searchController.addListener(filterSpecialists);
  }

  Future<void> fetchSpecialists() async {
    final response = await http.get(Uri.parse('http://192.168.0.230:5000/api/specialists'));
    if (response.statusCode == 200) {
      setState(() {
        specialists = parseSpecialists(response.body);
        filteredSpecialists = specialists;
      });
    } else {
      // Handle error if the response is not successful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching specialists')),
      );
    }
  }

  void filterSpecialists() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredSpecialists = specialists
          .where((s) => s.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Specialist'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search specialists...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredSpecialists.isEmpty
                ? Center(child: Text('No specialists available'))
                : ListView.builder(
                    itemCount: filteredSpecialists.length,
                    itemBuilder: (context, index) {
                      final specialist = filteredSpecialists[index];
                      return ListTile(
                        title: Text(specialist.name),
                        subtitle: Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(specialist.rating.toString()),
                          ],
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SpecialistProfilePage(
                                specialist: specialist,
                                isOrderFlow: true,
                                selectedDate: widget.selectedDate,
                                selectedTime: widget.selectedTime,
                                selectedChildren: widget.selectedChildren,
                                orderDescription: widget.description,
                                serviceType: widget.serviceType,
                              ),
                            ),
                          );

                          if (result != null && result is Map) {
                            Navigator.pop(context, result);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
