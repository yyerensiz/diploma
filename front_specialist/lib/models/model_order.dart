import 'model_child.dart';

class OrderModel {
  final int id;
  final String serviceType;
  final String description;
  final String status;
  final DateTime scheduledFor;
  final List<Child> children;

  OrderModel({
    required this.id,
    required this.serviceType,
    required this.description,
    required this.status,
    required this.scheduledFor,
    required this.children,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      serviceType: json['service_type'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      scheduledFor: DateTime.parse(json['scheduled_for']),
      children: (json['children'] as List<dynamic>? ?? [])
          .map((c) => Child.fromJson(c))
          .toList(),
    );
  }
}
