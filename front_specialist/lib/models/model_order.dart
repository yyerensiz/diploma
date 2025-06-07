//front_specialsts\lib\models\model_order.dart
import 'model_child.dart';

class Order {
  final int? id;
  final String serviceType;
  final String description;
  final String status;
  final DateTime scheduledFor;
  final double totalCost;
  final List<Child>? children;

  final int? specialistId;
  final Map<String, dynamic>? specialist;
  final List<int>? childrenIds;

  Order({
    this.id,
    required this.serviceType,
    required this.description,
    required this.status,
    required this.scheduledFor,
    required this.totalCost,
    this.children, 

    this.specialistId,
    this.specialist,
    this.childrenIds,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    
    final rawCost = json['total_cost'];
    double parsedTotalCost = rawCost is num
        ? rawCost.toDouble()
        : double.tryParse(rawCost.toString()) ?? 0.0;

    final List<int> ids = (json['child_ids'] as List? ?? []).cast<int>();

    final List<Child> kids = (json['children'] as List<dynamic>? ?? [])
        .map((c) => Child.fromJson(c as Map<String, dynamic>))
        .toList();

    return Order(
      id: json['id'],
      serviceType: json['service_type'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      scheduledFor: DateTime.parse(json['scheduled_for']),
      children: (json['children'] 
        as List<dynamic>? ?? []).map((c) => Child.fromJson(c)).toList(),
      totalCost: parsedTotalCost,

      specialistId: json['specialist_id'],
      specialist: json['specialist'] as Map<String, dynamic>?,
      childrenIds: ids,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      //'id': id,
      'service_type': serviceType,
      'description': description,
      'status': status,
      'scheduled_for': scheduledFor.toIso8601String(),
      'child_ids': children,
      'total_cost': totalCost,

      if (specialistId != null) 'specialist_id': specialistId,
    };
  }

  String? get specialistName {
    if (specialist == null) return null;
    if (specialist!['user'] != null) {
      return specialist!['user']['full_name'] as String?;
    }
    return (specialist!['full_name'] as String?) ??
           (specialist!['name'] as String?);
  }
}
