class Order {
  final String? id;
  final String serviceType;
  final String description;
  final String status;
  final DateTime scheduledFor;
  final List<int> childrenIds;
  final String? specialistId;
  final double totalCost;
  final Map<String, dynamic>? specialist; // Accepts nested specialist data

  Order({
    this.id,
    required this.serviceType,
    required this.description,
    required this.status,
    required this.scheduledFor,
    required this.childrenIds,
    this.specialistId,
    required this.totalCost,
    this.specialist, // Add to constructor
  });

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
  // If 'specialist' has nested 'user'
  if (specialist?['user'] != null) {
    return specialist?['user']?['full_name'] as String?;
  }
  // Fallback if not nested (just in case)
  return specialist?['full_name'] as String? ?? specialist?['name'] as String?;
}


  factory Order.fromJson(Map<String, dynamic> json) {
    final totalCostRaw = json['total_cost'];
    double parsedTotalCost;
    if (totalCostRaw is num) {
      parsedTotalCost = totalCostRaw.toDouble();
    } else if (totalCostRaw is String) {
      parsedTotalCost = double.tryParse(totalCostRaw) ?? 0.0;
    } else {
      parsedTotalCost = 0.0;
    }

    // Map child_ids to List<int> safely
    List<int> childrenList = [];
    if (json['child_ids'] is List) {
      childrenList = List<int>.from(json['child_ids']);
    }

    return Order(
      id: json['id']?.toString(),
      serviceType: json['service_type'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      scheduledFor: DateTime.parse(json['scheduled_for']),
      childrenIds: childrenList,
      specialistId: json['specialist_id']?.toString(),
      totalCost: parsedTotalCost,
      specialist: json['specialist'] as Map<String, dynamic>?, // Accepts nested map
    );
  }
}
