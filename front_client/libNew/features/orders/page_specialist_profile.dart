//front_client\lib\features\orders\page_specialist_profile.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:front_client/core/providers/provider_review.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/model_specialist.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/card_review.dart';
import 'page_service_details.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ReviewProvider>()
          .fetchReviewsForSpecialist(widget.specialist.id);
    });
  }

  Future<void> _handleRequestService() async {
    if (widget.isOrderFlow) return;
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
          Text("${key.tr()}: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.specialist;
    final reviewProv = context.watch<ReviewProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('specialist_profile_title'.tr()),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: (s.pfpUrl != null &&
                                s.pfpUrl!.isNotEmpty)
                            ? NetworkImage(s.pfpUrl!)
                            : const AssetImage(
                                    'assets/images/default_pfp.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 16),
                      Text(s.fullName,
                          style: Theme.of(context).textTheme.headlineSmall),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('about_specialist'.tr(),
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(s.bio ?? 'no_description'.tr()),
                      const SizedBox(height: 16),
                      _infoRow('hourly_rate',
                          s.hourlyRate != null ? '${s.hourlyRate} ₸/h' : '-'),
                      _infoRow(
                          'available_time', s.availableTimes ?? '-'),
                      _infoRow('certified',
                          s.verified == true ? 'yes'.tr() : 'no'.tr()),
                      _infoRow('phone', s.phone ?? '-'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('reviews'.tr(),
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            if (reviewProv.isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: LoadingIndicator()),
              )
            else if (reviewProv.errorMessage != null)
              Center(child: Text(reviewProv.errorMessage!))
            else if (reviewProv.reviews.isEmpty)
              Center(child: Text('no_reviews_yet'.tr()))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviewProv.reviews.length,
                itemBuilder: (_, i) {
                  final r = reviewProv.reviews[i];
                  final date = DateFormat.yMMMd(context.locale.toString())
                      .format(r.createdAt);
                  return CardReview(
                    authorName: r.clientName,
                    rating: r.rating.toDouble(),
                    date: date,
                    text: r.comment,
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
              child:
                  Text('request_order'.tr(), style: const TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ),
    );
  }
}
