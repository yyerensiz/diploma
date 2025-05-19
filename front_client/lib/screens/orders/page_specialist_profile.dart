import 'package:flutter/material.dart';
import 'package:front_client/models/model_order.dart';
import 'package:front_client/models/model_specialist.dart';
import 'package:front_client/screens/orders/page_service_order.dart';
import 'package:front_client/services/service_orders.dart';
import 'package:front_client/widgets/review_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SpecialistProfilePage extends StatefulWidget {
  final Specialist specialist;
  final bool isOrderFlow;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final List<int>? selectedChildren;
  final String? orderDescription;
  final String? serviceType;
  final double? totalCost;

  const SpecialistProfilePage({
    required this.specialist,
    this.isOrderFlow = false,
    this.selectedDate,
    this.selectedTime,
    this.selectedChildren,
    this.orderDescription,
    this.serviceType,
    this.totalCost,
    Key? key,
  }) : super(key: key);

  @override
  State<SpecialistProfilePage> createState() => _SpecialistProfilePageState();
}

class _SpecialistProfilePageState extends State<SpecialistProfilePage> {
  bool _isLoading = false;

  // Go to order creation, always preselect this specialist
  Future<void> _handleRequestService() async {
    if (_isLoading) return;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailsPage(
          serviceName: '', // let user choose in order page
          preselectedSpecialist: widget.specialist,
        ),
      ),
    );

    // After returning from order creation, show a confirmation if needed.
    // You can handle order completion/feedback here if you want.
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.specialist;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Specialist Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile picture and name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: s.pfpUrl != null && s.pfpUrl!.isNotEmpty
                        ? NetworkImage(s.pfpUrl!)
                        : const AssetImage('assets/images/default_pfp.png')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  Text(s.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(s.rating.toString(),
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ],
              ),
            ),
            // Specialist details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About Specialist', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(s.description ?? 'No description provided.'),
                  const SizedBox(height: 16),
                  _infoRow('Hourly Rate', s.hourlyRate != null ? '${s.hourlyRate} ₸/hr' : "-"),
                  _infoRow('Available Times', s.availableTimes ?? "-"),
                  _infoRow('Certified', s.verified == true ? "Yes" : "No"),
                  _infoRow('Phone', s.phone ?? "-"),
                  const SizedBox(height: 24),
                  Text('Reviews', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return ReviewCard(
                        authorName: 'Client ${index + 1}',
                        rating: 4.5,
                        date: '10 March 2024',
                        text:
                            'Very good specialist, punctual and responsible. The children are delighted!',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _handleRequestService,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Request Service', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ),
    );
  }

  // Helper for info lines
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }
}
