// front_client/lib/screens/orders/page_specialist_profile.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:front_client/models/model_specialist.dart';
import 'package:front_client/models/model_review.dart';
import 'package:front_client/screens/orders/page_service_order.dart';
import 'package:front_client/services/service_reviews.dart';
import 'package:front_client/widgets/review_card.dart';

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
  late Future<List<Review>> _reviewsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _reviewsFuture =
        ReviewService().fetchSpecialistReviews(widget.specialist.id);
  }

  Future<void> _handleRequestService() async {
    if (_isLoading) return;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailsPage(
          serviceName: widget.serviceType ?? '',
          preselectedSpecialist: widget.specialist,
        ),
      ),
    );
    // you can handle post-order logic here if needed
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.specialist;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Specialist Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.chat), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: (s.pfpUrl != null && s.pfpUrl!.isNotEmpty)
                        ? NetworkImage(s.pfpUrl!)
                        : const AssetImage('assets/images/default_pfp.png')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  Text(s.name,
                      style: Theme.of(context).textTheme.headlineSmall),
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

            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About Specialist',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(s.description ?? 'Нет описания'),
                  const SizedBox(height: 16),
                  _infoRow('Hourly rate',
                      s.hourlyRate != null ? '${s.hourlyRate} ₸/h' : '-'),
                  _infoRow('Available time', s.availableTimes ?? '-'),
                  _infoRow('Certified', s.verified == true ? 'Yes' : 'No'),
                  _infoRow('Phone', s.phone ?? '-'),
                  const SizedBox(height: 24),

                  // Reviews header
                  Text('Reviews',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),

                  // Reviews list
                  FutureBuilder<List<Review>>(
                    future: _reviewsFuture,
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snap.hasError) {
                        return const Text('Ошибка загрузки отзывов');
                      }
                      final reviews = snap.data ?? [];
                      if (reviews.isEmpty) {
                        return const Text('Пока нет отзывов');
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (_, i) {
                          final r = reviews[i];
                          final date =
                              DateFormat('dd MMM yyyy').format(r.createdAt);
                          return ReviewCard(
                            authorName: r.clientName,
                            rating: r.rating.toDouble(),
                            date: date,
                            text: r.comment,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom “Request Service” button
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _handleRequestService,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child:
                  Text('Request order', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ),
    );
  }
}
