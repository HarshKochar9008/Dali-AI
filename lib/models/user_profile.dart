class UserProfile {
  final String fullName;
  final String gender; // 'Male' | 'Female' | 'Other' | ''
  final DateTime? dateOfBirth;
  final String timeOfBirth; // HH:mm (24h) or ''
  final String locationName;
  final double? latitude;
  final double? longitude;

  const UserProfile({
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });

  static const empty = UserProfile(
    fullName: '',
    gender: '',
    dateOfBirth: null,
    timeOfBirth: '',
    locationName: '',
    latitude: null,
    longitude: null,
  );

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'timeOfBirth': timeOfBirth,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
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
      gender: (json['gender'] ?? '') as String,
      dateOfBirth: parsedDob,
      timeOfBirth: (json['timeOfBirth'] ?? '') as String,
      locationName: (json['locationName'] ?? '') as String,
      latitude: (json['latitude'] is num) ? (json['latitude'] as num).toDouble() : null,
      longitude:
          (json['longitude'] is num) ? (json['longitude'] as num).toDouble() : null,
    );
  }
}

