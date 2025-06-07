//front_client\lib\features\orders\page_service_details.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:front_client/core/providers/provider_children.dart';
import 'package:front_client/core/providers/provider_order.dart';
import 'package:provider/provider.dart';
import '../../core/models/model_order.dart';
import '../../core/models/model_specialist.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/filter_chip.dart';

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
  final _descriptionCtl = TextEditingController();
  final _costCtl = TextEditingController();
  bool _isLoading = false;
  String? selectedServiceType;

  final List<String> _services = [
    'Child Transportation',
    'Homework Help',
    'Household Help',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChildrenProvider>().fetchChildren();
    });
    if (_services.contains(widget.serviceName)) {
      selectedServiceType = widget.serviceName;
    }
  }

  @override
  void dispose() {
    _descriptionCtl.dispose();
    _costCtl.dispose();
    super.dispose();
  }

  String _translateService(String s) {
    switch (s) {
      case 'Child Transportation':
        return 'service_child_transportation'.tr();
      case 'Homework Help':
        return 'service_homework_help'.tr();
      case 'Household Help':
        return 'service_household_help'.tr();
      default:
        return s;
    }
  }

  Future<void> _submitOrder() async {
    if (selectedDate == null ||
        selectedTime == null ||
        selectedChildrenIds.isEmpty ||
        selectedServiceType == null ||
        widget.preselectedSpecialist == null ||
        _costCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('fill_required_fields_error'.tr())),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final order = Order(
        serviceType: selectedServiceType!,
        description: _descriptionCtl.text,
        status: 'pending',
        scheduledFor: DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          selectedTime!.hour,
          selectedTime!.minute,
        ),
        childrenIds: selectedChildrenIds,
        specialistId: widget.preselectedSpecialist!.id,
        totalCost: double.tryParse(_costCtl.text) ?? 0.0,
      );
      await context.read<OrderProvider>().createOrder(order);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('order_created_success'.tr())),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('failed_create_order'.tr(args: [e.toString()]))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final childrenProv = context.watch<ChildrenProvider>();
    final children = childrenProv.children;
    final isLoadingChildren = childrenProv.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text('service_request_title'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.preselectedSpecialist != null) ...[
              Text('label_specialist'.tr(),
                  style: Theme.of(context).textTheme.titleLarge),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      widget.preselectedSpecialist!.pfpUrl != null &&
                              widget.preselectedSpecialist!.pfpUrl!.isNotEmpty
                          ? NetworkImage(widget.preselectedSpecialist!.pfpUrl!)
                          : const AssetImage('assets/images/default_pfp.png')
                              as ImageProvider,
                ),
                title: Text(widget.preselectedSpecialist!.fullName),
                subtitle: Text(widget.preselectedSpecialist!.phone ?? ''),
              ),
              const SizedBox(height: 16),
            ],
            Text('service_type_label'.tr(),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedServiceType,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                hintText: 'select_service_type_hint'.tr(),
              ),
              items: _services
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(_translateService(s)),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedServiceType = val),
            ),
            const SizedBox(height: 24),
            Text('select_datetime_label'.tr(),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    selectedDate != null
                        ? DateFormat.yMd(context.locale.toString())
                            .format(selectedDate!)
                        : 'choose_date'.tr(),
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
                        ? selectedTime!.format(context)
                        : 'choose_time'.tr(),
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
            Text('select_children_label'.tr(),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (isLoadingChildren)
              const Center(child: LoadingIndicator())
            else if (children.isEmpty)
              Center(child: Text('no_children_found'.tr()))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: children.map((child) {
                  final selected = selectedChildrenIds.contains(child.id);
                  return ChipFilter(
                    label: child.name,
                    selected: selected,
                    onSelected: (b) => setState(() {
                      if (b)
                        selectedChildrenIds.add(child.id);
                      else
                        selectedChildrenIds.remove(child.id);
                    }),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),
            Text('description_for_specialist_label'.tr(),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionCtl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'describe_requirements_hint'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text('total_cost_label'.tr(),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _costCtl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'enter_total_cost_hint'.tr(),
                prefixText: '₸ ',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: LoadingIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitOrder,
                      child: Text('submit_order_label'.tr(),
                          style: const TextStyle(fontSize: 18)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
