class Subsidy {
  final int id;
  final int clientId;
  final double percentage;
  final bool active;

  Subsidy({
    required this.id,
    required this.clientId,
    required this.percentage,
    required this.active,
  });

  factory Subsidy.fromJson(Map<String, dynamic> json) {
    // Parse id
    final dynamic idJson = json['id'];
    final int id = idJson is int
        ? idJson
        : int.tryParse(idJson?.toString() ?? '') ?? 0;

    // Parse clientId
    final dynamic clientJson = json['client_id'];
    final int clientId = clientJson is int
        ? clientJson
        : int.tryParse(clientJson?.toString() ?? '') ?? 0;

    // Parse percentage (handles both num and String)
    final dynamic percJson = json['percentage'];
    double percentage;
    if (percJson is num) {
      percentage = percJson.toDouble();
    } else if (percJson is String) {
      percentage = double.tryParse(percJson) ?? 0.0;
    } else {
      percentage = 0.0;
    }

    // Parse active (handles bool, num, and String)
    final dynamic activeJson = json['active'];
    bool active;
    if (activeJson is bool) {
      active = activeJson;
    } else if (activeJson is num) {
      active = activeJson != 0;
    } else if (activeJson is String) {
      active = activeJson.toLowerCase() == 'true';
    } else {
      active = true;
    }

    return Subsidy(
      id: id,
      clientId: clientId,
      percentage: percentage,
      active: active,
    );
  }
}