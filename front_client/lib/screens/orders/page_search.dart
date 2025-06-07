//front_client\lib\screens\orders\page_search.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
        filteredSpecialists = widget.specialists
            .where((s) => s.fullName.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _showServiceDescription(BuildContext context, String serviceKey) {
    final title = serviceKey.tr();
    final desc = '${serviceKey}_desc'.tr();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(desc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ok'.tr()),
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
          Text('services'.tr(), style: Theme.of(context).textTheme.titleLarge),
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
                title: 'service_child_transportation'.tr(),
                onTap: () =>
                    _showServiceDescription(context, 'service_child_transportation'),
              ),
              ServiceCard(
                icon: Icons.school,
                title: 'service_homework_help'.tr(),
                onTap: () =>
                    _showServiceDescription(context, 'service_homework_help'),
              ),
              ServiceCard(
                icon: Icons.home,
                title: 'service_household_help'.tr(),
                onTap: () =>
                    _showServiceDescription(context, 'service_household_help'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('specialists'.tr(), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'search_specialists_hint'.tr(),
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          if (filteredSpecialists.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'no_specialists_found'.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredSpecialists.length,
              itemBuilder: (context, index) {
                final specialist = filteredSpecialists[index];
                return SpecialistCard(
                  name: specialist.fullName,
                  rating: specialist.rating,
                  imageUrl: specialist.pfpUrl ?? '',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SpecialistProfilePage(
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
