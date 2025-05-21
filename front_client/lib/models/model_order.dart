//front_client\lib\models\model_order.dart
import 'model_child.dart';

class Order {
  final String? id;
  final String serviceType;
  final String description;
  final String status;
  final DateTime scheduledFor;
  final List<int> childrenIds;
  final List<Child> children;        // ← NEW
  final String? specialistId;
  final double totalCost;
  final Map<String, dynamic>? specialist;

  Order({
    this.id,
    required this.serviceType,
    required this.description,
    required this.status,
    required this.scheduledFor,
    required this.childrenIds,
    this.children = const [],         // ← NEW DEFAULT
    this.specialistId,
    required this.totalCost,
    this.specialist,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // parse totalCost etc...
    final rawCost = json['total_cost'];
    double parsedTotalCost = rawCost is num
        ? rawCost.toDouble()
        : double.tryParse(rawCost.toString()) ?? 0.0;

    // IDs array
    final List<int> ids = (json['child_ids'] as List? ?? []).cast<int>();

    // CHILDREN objects array (if your backend now includes them)
    final List<Child> kids = (json['children'] as List<dynamic>? ?? [])
        .map((c) => Child.fromJson(c as Map<String, dynamic>))
        .toList();

    return Order(
      id: json['id']?.toString(),
      serviceType: json['service_type'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      scheduledFor: DateTime.parse(json['scheduled_for']),
      childrenIds: ids,
      children: kids,                         // ← pass them in
      specialistId: json['specialist_id']?.toString(),
      totalCost: parsedTotalCost,
      specialist: json['specialist'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'service_type': serviceType,
      'description': description,
      'status': status,
      'scheduled_for': scheduledFor.toIso8601String(),
      'child_ids': childrenIds,
      if (specialistId != null) 'specialist_id': specialistId,
      'total_cost': totalCost,
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
