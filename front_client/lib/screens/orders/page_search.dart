import 'package:flutter/material.dart';
import 'package:front_client/models/model_specialist.dart';
import 'package:front_client/screens/orders/page_specialist_profile.dart';
import 'package:front_client/widgets/service_card.dart';
import 'package:front_client/widgets/specialist_card.dart';

class SearchPage extends StatefulWidget {
  final List<Specialist> specialists;

  const SearchPage({required this.specialists, Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late List<Specialist> filteredSpecialists;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredSpecialists = widget.specialists;
    _searchController.addListener(_filterSpecialists);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSpecialists() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredSpecialists = widget.specialists;
      } else {
        filteredSpecialists = widget.specialists.where((s) {
          return s.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _showServiceDescription(BuildContext context, String serviceName) {
    String desc;
    switch (serviceName) {
      case 'Child Transportation':
        desc = "Our specialists can safely transport your child to and from school or activities.";
        break;
      case 'Homework Help':
        desc = "Get help with your child's homework from experienced tutors and mentors.";
        break;
      case 'Household Help':
        desc = "Skilled specialists ready to assist with a variety of household tasks.";
        break;
      default:
        desc = "Service description not available.";
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(serviceName),
        content: Text(desc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Service',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          // Services grid
          Text(
            'Services',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              ServiceCard(
                icon: Icons.directions_car,
                title: 'Child Transportation',
                onTap: () => _showServiceDescription(context, 'Child Transportation'),
              ),
              ServiceCard(
                icon: Icons.school,
                title: 'Homework Help',
                onTap: () => _showServiceDescription(context, 'Homework Help'),
              ),
              ServiceCard(
                icon: Icons.home,
                title: 'Household Help',
                onTap: () => _showServiceDescription(context, 'Household Help'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Search bar below services
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search specialists...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Specialists',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          filteredSpecialists.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    "No specialists found.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredSpecialists.length,
                  itemBuilder: (context, index) {
                    final specialist = filteredSpecialists[index];
                    return SpecialistCard(
                      name: specialist.name,
                      rating: specialist.rating,
                      imageUrl: specialist.pfpUrl ?? '',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SpecialistProfilePage(
                              specialist: specialist,
                              isOrderFlow: false,
                              selectedDate: null,
                              selectedTime: null,
                              selectedChildren: null,
                              orderDescription: null,
                              serviceType: null,
                              totalCost: null,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}
