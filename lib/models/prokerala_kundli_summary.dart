class ProkeralaKundliSummary {
  final NakshatraDetails? nakshatraDetails;
  final MangalDosha? mangalDosha;
  final List<YogaDetail> yogaDetails;

  const ProkeralaKundliSummary({
    required this.nakshatraDetails,
    required this.mangalDosha,
    required this.yogaDetails,
  });

  factory ProkeralaKundliSummary.fromApiResponse(Map<String, dynamic> json) {
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? const {};

    final nakshatraDetailsJson =
        (data['nakshatra_details'] as Map?)?.cast<String, dynamic>();
    final mangalDoshaJson =
        (data['mangal_dosha'] as Map?)?.cast<String, dynamic>();

    final yogaList = <YogaDetail>[];
    final yogaJson = data['yoga_details'];
    if (yogaJson is List) {
      for (final item in yogaJson) {
        if (item is Map) {
          yogaList.add(YogaDetail.fromJson(item.cast<String, dynamic>()));
        }
      }
    }

    return ProkeralaKundliSummary(
      nakshatraDetails: nakshatraDetailsJson == null
          ? null
          : NakshatraDetails.fromJson(nakshatraDetailsJson),
      mangalDosha:
          mangalDoshaJson == null ? null : MangalDosha.fromJson(mangalDoshaJson),
      yogaDetails: yogaList,
    );
  }
}

class NakshatraDetails {
  final Nakshatra? nakshatra;
  final Rasi? chandraRasi;
  final Rasi? sooryaRasi;
  final Zodiac? zodiac;
  final AdditionalInfo? additionalInfo;

  const NakshatraDetails({
    required this.nakshatra,
    required this.chandraRasi,
    required this.sooryaRasi,
    required this.zodiac,
    required this.additionalInfo,
  });

  factory NakshatraDetails.fromJson(Map<String, dynamic> json) {
    return NakshatraDetails(
      nakshatra: json['nakshatra'] is Map
          ? Nakshatra.fromJson((json['nakshatra'] as Map).cast<String, dynamic>())
          : null,
      chandraRasi: json['chandra_rasi'] is Map
          ? Rasi.fromJson((json['chandra_rasi'] as Map).cast<String, dynamic>())
          : null,
      sooryaRasi: json['soorya_rasi'] is Map
          ? Rasi.fromJson((json['soorya_rasi'] as Map).cast<String, dynamic>())
          : null,
      zodiac: json['zodiac'] is Map
          ? Zodiac.fromJson((json['zodiac'] as Map).cast<String, dynamic>())
          : null,
      additionalInfo: json['additional_info'] is Map
          ? AdditionalInfo.fromJson(
              (json['additional_info'] as Map).cast<String, dynamic>(),
            )
          : null,
    );
  }
}

class Nakshatra {
  final int? id;
  final String? name;
  final PlanetLord? lord;
  final int? pada;

  const Nakshatra({
    required this.id,
    required this.name,
    required this.lord,
    required this.pada,
  });

  factory Nakshatra.fromJson(Map<String, dynamic> json) {
    return Nakshatra(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      name: json['name']?.toString(),
      lord: json['lord'] is Map
          ? PlanetLord.fromJson((json['lord'] as Map).cast<String, dynamic>())
          : null,
      pada: json['pada'] is num ? (json['pada'] as num).toInt() : null,
    );
  }
}

class Rasi {
  final int? id;
  final String? name;
  final PlanetLord? lord;

  const Rasi({
    required this.id,
    required this.name,
    required this.lord,
  });

  factory Rasi.fromJson(Map<String, dynamic> json) {
    return Rasi(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      name: json['name']?.toString(),
      lord: json['lord'] is Map
          ? PlanetLord.fromJson((json['lord'] as Map).cast<String, dynamic>())
          : null,
    );
  }
}

class Zodiac {
  final int? id;
  final String? name;

  const Zodiac({
    required this.id,
    required this.name,
  });

  factory Zodiac.fromJson(Map<String, dynamic> json) {
    return Zodiac(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      name: json['name']?.toString(),
    );
  }
}

class PlanetLord {
  final int? id;
  final String? name;
  final String? vedicName;

  const PlanetLord({
    required this.id,
    required this.name,
    required this.vedicName,
  });

  factory PlanetLord.fromJson(Map<String, dynamic> json) {
    return PlanetLord(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      name: json['name']?.toString(),
      vedicName: json['vedic_name']?.toString(),
    );
  }
}

class AdditionalInfo {
  final Map<String, dynamic> raw;

  const AdditionalInfo({required this.raw});

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) {
    // Keep it flexible (Prokerala can add/remove fields).
    return AdditionalInfo(raw: Map<String, dynamic>.from(json));
  }

  String? operator [](String key) => raw[key]?.toString();
}

class MangalDosha {
  final bool hasDosha;
  final String? description;

  const MangalDosha({
    required this.hasDosha,
    required this.description,
  });

  factory MangalDosha.fromJson(Map<String, dynamic> json) {
    return MangalDosha(
      hasDosha: json['has_dosha'] == true,
      description: json['description']?.toString(),
    );
  }
}

class YogaDetail {
  final String? name;
  final String? description;

  const YogaDetail({
    required this.name,
    required this.description,
  });

  factory YogaDetail.fromJson(Map<String, dynamic> json) {
    return YogaDetail(
      name: json['name']?.toString(),
      description: json['description']?.toString(),
    );
  }
}

