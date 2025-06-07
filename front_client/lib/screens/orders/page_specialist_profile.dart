//front_client\lib\screens\orders\page_specialist_profile.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
    _reviewsFuture = ReviewService().fetchSpecialistReviews(widget.specialist.id);
  }

  Future<void> _handleRequestService() async {
    if (_isLoading) return;
    await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailsPage(
          serviceName: widget.serviceType ?? '',
          preselectedSpecialist: widget.specialist,
        ),
      ),
    );
  }

  Widget _infoRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("${key.tr()}: ", style: const TextStyle(fontWeight: FontWeight.bold)),
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
        title: Text('specialist_profile_title'.tr()),
        //actions: [IconButton(icon: const Icon(Icons.chat), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: (s.pfpUrl != null && s.pfpUrl!.isNotEmpty)
                            ? NetworkImage(s.pfpUrl!)
                            : const AssetImage('assets/images/default_pfp.png') as ImageProvider,
                      ),
                      const SizedBox(height: 16),
                      Text(s.fullName, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            s.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Professional Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('about_specialist'.tr(), style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(s.bio ?? 'no_description'.tr()),
                      const SizedBox(height: 16),
                      _infoRow('hourly_rate', s.hourlyRate != null ? '${s.hourlyRate} ₸/h' : '-'),
                      _infoRow('available_time', s.availableTimes ?? '-'),
                      _infoRow('certified', s.verified == true ? 'yes'.tr() : 'no'.tr()),
                      _infoRow('phone', s.phone ?? '-'),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Reviews Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('reviews'.tr(), style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Review>>(
              future: _reviewsFuture,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) {
                  return Center(child: Text('error_loading_reviews'.tr()));
                }
                final reviews = snap.data ?? [];
                if (reviews.isEmpty) {
                  return Center(child: Text('no_reviews_yet'.tr()));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (_, i) {
                    final r = reviews[i];
                    final date = DateFormat.yMMMd(context.locale.toString()).format(r.createdAt);
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _handleRequestService,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('request_order'.tr(), style: const TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ),
    );
  }
}
