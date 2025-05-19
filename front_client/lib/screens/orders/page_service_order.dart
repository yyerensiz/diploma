import 'package:flutter/material.dart';
import 'package:front_client/models/model_order.dart';
import 'package:front_client/models/model_specialist.dart';
import 'package:front_client/services/service_orders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/children_provider.dart';
import 'package:front_client/models/model_child.dart';

class ServiceDetailsPage extends StatefulWidget {
  final String serviceName;
  final Specialist? preselectedSpecialist;

  const ServiceDetailsPage({
    required this.serviceName,
    this.preselectedSpecialist,
    Key? key,
  }) : super(key: key);

  @override
  _ServiceDetailsPageState createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<int> selectedChildrenIds = [];
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  bool _isLoading = false;
  String? selectedServiceType; // allow user to choose

  final List<String> _services = [
    'Child Transportation',
    'Homework Help',
    'Household Help'
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<ChildrenProvider>(context, listen: false).fetchChildren();
    selectedServiceType = widget.serviceName.isNotEmpty ? widget.serviceName : null;
  }

  @override
  void dispose() {
    descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (selectedDate == null ||
        selectedTime == null ||
        selectedChildrenIds.isEmpty ||
        selectedServiceType == null ||
        _costController.text.trim().isEmpty ||
        widget.preselectedSpecialist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Not logged in';
      final token = await user.getIdToken();

      final order = Order(
        serviceType: selectedServiceType!,
        description: descriptionController.text,
        status: 'pending',
        scheduledFor: DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          selectedTime!.hour,
          selectedTime!.minute,
        ),
        childrenIds: selectedChildrenIds,
        specialistId: widget.preselectedSpecialist!.id.toString(),
        totalCost: double.tryParse(_costController.text) ?? 0.0,
      );

      print('Sending order: ${order.toJson()}');
      await OrderService().createOrder(token!, order);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created successfully!')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create order: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final childrenProvider = Provider.of<ChildrenProvider>(context);
    final children = childrenProvider.children;
    final isLoadingChildren = childrenProvider.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Request Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show which specialist the order will be for
            if (widget.preselectedSpecialist != null) ...[
              Text('Specialist:', style: Theme.of(context).textTheme.titleLarge),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: widget.preselectedSpecialist!.pfpUrl != null && widget.preselectedSpecialist!.pfpUrl!.isNotEmpty
                      ? NetworkImage(widget.preselectedSpecialist!.pfpUrl!)
                      : const AssetImage('assets/images/default_pfp.png') as ImageProvider,
                ),
                title: Text(widget.preselectedSpecialist!.name),
                subtitle: Text(widget.preselectedSpecialist!.phone ?? ''),
              ),
              const SizedBox(height: 16),
            ],

            Text('Service Type', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedServiceType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _services
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => selectedServiceType = val),
              hint: const Text('Select service type'),
            ),
            const SizedBox(height: 24),

            Text('Select Date and Time', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    selectedDate != null
                        ? '${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}'
                        : 'Choose date',
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) setState(() => selectedDate = date);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    selectedTime != null
                        ? '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                        : 'Choose time',
                  ),
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) setState(() => selectedTime = time);
                  },
                ),
              ),
            ]),

            const SizedBox(height: 24),
            Text('Select Children', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (isLoadingChildren)
              const CircularProgressIndicator()
            else if (children.isEmpty)
              const Text('No children found.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: children.map((child) {
                  final selected = selectedChildrenIds.contains(child.id);
                  return FilterChip(
                    label: Text('${child.name}'),
                    selected: selected,
                    onSelected: (b) {
                      setState(() {
                        if (b == true) selectedChildrenIds.add(child.id);
                        else selectedChildrenIds.remove(child.id);
                      });
                    },
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),
            Text('Description for Specialist', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe your requirements…',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),
            Text('Total Cost', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _costController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Enter total cost',
                prefixText: '\₸ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitOrder,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Order', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
