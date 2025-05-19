// lib/models/model_specialist.dart
class SpecialistProfile {
  final int id;
  final String? bio;
  final double? hourlyRate;
  final double? rating;
  final String? availableTimes;
  final bool? verified;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? pfpUrl;

  SpecialistProfile({
    required this.id,
    this.bio,
    this.hourlyRate,
    this.rating,
    this.availableTimes,
    this.verified,
    this.fullName,
    this.email,
    this.phone,
    this.pfpUrl,
  });

  factory SpecialistProfile.fromJson(Map<String, dynamic> json) {
    // Parse hourly_rate whether it's a number or a string
    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    return SpecialistProfile(
      id: json['id'] as int,
      bio: json['bio'] as String?,
      hourlyRate: parseDouble(json['hourly_rate']),
      rating: parseDouble(json['rating']),
      availableTimes: json['available_times'] as String?,
      verified: json['verified'] == true,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      pfpUrl: json['pfp_url'] as String?,
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
