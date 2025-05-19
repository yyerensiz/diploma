class UserProfile {
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String profileImageUrl;

  UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.profileImageUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      
      fullName: json['full_name']?? '',
      email: json['email']?? '',
      phone: json['phone']?? '',
      address: json['address']?? '',
      profileImageUrl: json['pfp_url'] ?? 'https://img.freepik.com/free-vector/blue-circle-with-white-user_78370-4707.jpg', // fallback if null
    );
  }
}
