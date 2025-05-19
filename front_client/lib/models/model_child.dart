class Child {
  final int id;
  final String name;
  final DateTime dateOfBirth;
  final String? bio;
  final String? pfpUrl;

  Child({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    this.bio,
    this.pfpUrl,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      name: json['full_name'],
      dateOfBirth: DateTime.parse(json['birth_date']),
      bio: json['bio'],
      pfpUrl: json['pfp_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'full_name': name,
    'birth_date': dateOfBirth.toIso8601String(),
    'bio': bio,
    'pfp_url': pfpUrl,
  };
}
