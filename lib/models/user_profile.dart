class UserProfile {
  final String fullName;
  final String email; // optional email
  final String gender; // 'Male' | 'Female' | 'Other' | ''
  final DateTime? dateOfBirth;
  final String timeOfBirth; // HH:mm (24h) or ''
  final String locationName;
  final double? latitude;
  final double? longitude;
  final String phone; // optional phone number

  const UserProfile({
    required this.fullName,
    this.email = '',
    required this.gender,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    this.phone = '',
  });

  static const empty = UserProfile(
    fullName: '',
    email: '',
    gender: '',
    dateOfBirth: null,
    timeOfBirth: '',
    locationName: '',
    latitude: null,
    longitude: null,
    phone: '',
  );

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'timeOfBirth': timeOfBirth,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDob;
    final dobRaw = json['dateOfBirth'];
    if (dobRaw is String && dobRaw.isNotEmpty) {
      parsedDob = DateTime.tryParse(dobRaw);
    }

    return UserProfile(
      fullName: (json['fullName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      gender: (json['gender'] ?? '') as String,
      dateOfBirth: parsedDob,
      timeOfBirth: (json['timeOfBirth'] ?? '') as String,
      locationName: (json['locationName'] ?? '') as String,
      latitude: (json['latitude'] is num)
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: (json['longitude'] is num)
          ? (json['longitude'] as num).toDouble()
          : null,
      phone: (json['phone'] ?? '') as String,
    );
  }
}
