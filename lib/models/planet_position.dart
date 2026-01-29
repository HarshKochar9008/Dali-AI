class PlanetPositionResult {
  final List<PlanetPosition> planets;

  const PlanetPositionResult({
    required this.planets,
  });

  factory PlanetPositionResult.fromApiResponse(Map<String, dynamic> json) {
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    
    final planetsList = <PlanetPosition>[];
    
    // Try different possible field names for planets
    final planetsJson = data['planets'] ?? 
                       data['planet_positions'] ?? 
                       data['planet_position'];
    
    if (planetsJson is List) {
      for (final item in planetsJson) {
        if (item is Map) {
          planetsList.add(PlanetPosition.fromJson(item.cast<String, dynamic>()));
        }
      }
    } else if (planetsJson is Map) {
      // If planets is a map (keyed by planet name), convert to list
      final planetsMap = planetsJson.cast<String, dynamic>();
      for (final entry in planetsMap.entries) {
        if (entry.value is Map) {
          final planetData = (entry.value as Map).cast<String, dynamic>();
          planetData['name'] = entry.key; // Add name if missing
          planetsList.add(PlanetPosition.fromJson(planetData));
        }
      }
    }

    return PlanetPositionResult(planets: planetsList);
  }
}

class PlanetPosition {
  final int? id;
  final String? name;
  final double? longitude;
  final double? latitude;
  final double? latitudeSpeed;
  final double? longitudeSpeed;
  final double? distance;
  final double? distanceSpeed;
  final double? altitude;
  final double? altitudeSpeed;
  final double? azimuth;
  final double? azimuthSpeed;
  final bool? isRetrograde;
  final SignDetails? sign;
  final NakshatraDetails? nakshatra;
  final HouseDetails? house;

  const PlanetPosition({
    this.id,
    this.name,
    this.longitude,
    this.latitude,
    this.latitudeSpeed,
    this.longitudeSpeed,
    this.distance,
    this.distanceSpeed,
    this.altitude,
    this.altitudeSpeed,
    this.azimuth,
    this.azimuthSpeed,
    this.isRetrograde,
    this.sign,
    this.nakshatra,
    this.house,
  });

  factory PlanetPosition.fromJson(Map<String, dynamic> json) {
    return PlanetPosition(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      name: json['name']?.toString(),
      longitude: json['longitude'] is num ? (json['longitude'] as num).toDouble() : null,
      latitude: json['latitude'] is num ? (json['latitude'] as num).toDouble() : null,
      latitudeSpeed: json['latitude_speed'] is num ? (json['latitude_speed'] as num).toDouble() : null,
      longitudeSpeed: json['longitude_speed'] is num ? (json['longitude_speed'] as num).toDouble() : null,
      distance: json['distance'] is num ? (json['distance'] as num).toDouble() : null,
      distanceSpeed: json['distance_speed'] is num ? (json['distance_speed'] as num).toDouble() : null,
      altitude: json['altitude'] is num ? (json['altitude'] as num).toDouble() : null,
      altitudeSpeed: json['altitude_speed'] is num ? (json['altitude_speed'] as num).toDouble() : null,
      azimuth: json['azimuth'] is num ? (json['azimuth'] as num).toDouble() : null,
      azimuthSpeed: json['azimuth_speed'] is num ? (json['azimuth_speed'] as num).toDouble() : null,
      isRetrograde: json['is_retrograde'] == true,
      sign: json['sign'] is Map
          ? SignDetails.fromJson((json['sign'] as Map).cast<String, dynamic>())
          : null,
      nakshatra: json['nakshatra'] is Map
          ? NakshatraDetails.fromJson((json['nakshatra'] as Map).cast<String, dynamic>())
          : null,
      house: json['house'] is Map
          ? HouseDetails.fromJson((json['house'] as Map).cast<String, dynamic>())
          : null,
    );
  }

  /// Get longitude in degrees, minutes, seconds format
  String get longitudeFormatted {
    if (longitude == null) return 'N/A';
    return _formatDegrees(longitude!);
  }

  /// Get latitude in degrees, minutes, seconds format
  String get latitudeFormatted {
    if (latitude == null) return 'N/A';
    return _formatDegrees(latitude!);
  }

  String _formatDegrees(double degrees) {
    final d = degrees.floor();
    final minutes = ((degrees - d) * 60).floor();
    final seconds = (((degrees - d) * 60 - minutes) * 60).round();
    return '${d}° ${minutes}\' ${seconds}"';
  }
}

class SignDetails {
  final int? id;
  final String? name;
  final String? vedicName;

  const SignDetails({
    this.id,
    this.name,
    this.vedicName,
  });

  factory SignDetails.fromJson(Map<String, dynamic> json) {
    return SignDetails(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      name: json['name']?.toString(),
      vedicName: json['vedic_name']?.toString(),
    );
  }
}

class NakshatraDetails {
  final int? id;
  final String? name;
  final int? pada;
  final PlanetLord? lord;

  const NakshatraDetails({
    this.id,
    this.name,
    this.pada,
    this.lord,
  });

  factory NakshatraDetails.fromJson(Map<String, dynamic> json) {
    return NakshatraDetails(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      name: json['name']?.toString(),
      pada: json['pada'] is num ? (json['pada'] as num).toInt() : null,
      lord: json['lord'] is Map
          ? PlanetLord.fromJson((json['lord'] as Map).cast<String, dynamic>())
          : null,
    );
  }
}

class PlanetLord {
  final int? id;
  final String? name;
  final String? vedicName;

  const PlanetLord({
    this.id,
    this.name,
    this.vedicName,
  });

  factory PlanetLord.fromJson(Map<String, dynamic> json) {
    return PlanetLord(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      name: json['name']?.toString(),
      vedicName: json['vedic_name']?.toString(),
    );
  }
}

class HouseDetails {
  final int? id;
  final String? name;

  const HouseDetails({
    this.id,
    this.name,
  });

  factory HouseDetails.fromJson(Map<String, dynamic> json) {
    return HouseDetails(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      name: json['name']?.toString(),
    );
  }
}
