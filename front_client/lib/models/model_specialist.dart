//front_client\lib\models\model_specialist.dart
class Specialist {
  final int id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? pfpUrl;

  final double rating;
  final String? bio;
  final double? hourlyRate;
  final String? availableTimes;
  final bool? verified;
  
  Specialist({
    required this.id,
    required this.fullName,
    required this.rating,
    this.email,
    this.phone,
    this.pfpUrl,

    this.bio,
    this.hourlyRate,
    this.availableTimes,
    this.verified,
  });

  factory Specialist.fromJson(Map<String, dynamic> json) {
    // Parse hourly_rate whether it's a number or a string
    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    return Specialist(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      pfpUrl: json['pfp_url'] as String?,
      
      rating: (json['rating'] ?? 0).toDouble(),
      bio: json['bio'] as String?,
      hourlyRate: parseDouble(json['hourly_rate']),
      availableTimes: json['available_times'] as String?,
      verified: json['verified'] == true,
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'bio': bio,
        'hourly_rate': hourlyRate,
        'rating': rating,
        'available_times': availableTimes,
        'verified': verified,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'pfp_url': pfpUrl,
  };
}
