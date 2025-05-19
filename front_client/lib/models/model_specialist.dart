class Specialist {
  final int id;
  final String name;
  final double rating;
  final String? description;
  final double? hourlyRate;
  final String? availableTimes;
  final bool? verified;
  final String? phone;
  final String? pfpUrl;

  Specialist({
    required this.id,
    required this.name,
    required this.rating,
    this.description,
    this.hourlyRate,
    this.availableTimes,
    this.verified,
    this.phone,
    this.pfpUrl,
  });

  factory Specialist.fromJson(Map<String, dynamic> json) {
    return Specialist(
      id: json['id'],
      name: json['name'],
      rating: (json['rating'] ?? 0).toDouble(),
      description: json['description'],
      hourlyRate: json['hourly_rate'] != null ? double.tryParse(json['hourly_rate'].toString()) : null,
      availableTimes: json['available_times'],
      verified: json['verified'],
      phone: json['phone'],
      pfpUrl: json['pfp_url'],
    );
  }
}
