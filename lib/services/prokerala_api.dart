import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/kundali_data.dart';
import '../models/planet_position.dart';

class ProkeralaApi {
  /// Base URL for the Node/Express proxy (NOT Prokerala directly).
  ///
  /// Override at build/run time:
  /// `flutter run --dart-define=KUNDLI_PROXY_BASE_URL=http://localhost:3000`
  ///
  /// Notes:
  /// - Android emulator uses `http://10.0.2.2:3000`
  /// - iOS simulator can use `http://localhost:3000`
  static const String _proxyBaseUrl = String.fromEnvironment(
    'KUNDLI_PROXY_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static String _formatTimezoneOffset(Duration offset) {
    // Prokerala expects an explicit offset like +05:30 (not a bare local time).
    final isNegative = offset.isNegative;
    final abs = offset.abs();
    final hours = abs.inHours.toString().padLeft(2, '0');
    final minutes = (abs.inMinutes % 60).toString().padLeft(2, '0');
    final sign = isNegative ? '-' : '+';
    return '$sign$hours:$minutes';
  }

  static String _two(int v) => v.toString().padLeft(2, '0');

  /// Calls `/v2/astrology/kundli` and returns the decoded JSON response.
  ///
  /// This keeps the response as a raw `Map<String, dynamic>` so that
  /// you can experiment with the exact structure before wiring it
  /// into your existing `KundaliData` model.
  static Future<Map<String, dynamic>> fetchKundli({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    int ayanamsa = 1,
    String? language,
  }) async {
    // Prokerala expects an ISO datetime that includes the local timezone offset.
    // Use a strict format without fractional seconds:
    // `YYYY-MM-DDTHH:mm:ss+HH:MM`
    final isoString = '${birthDateTime.year.toString().padLeft(4, '0')}-'
        '${_two(birthDateTime.month)}-'
        '${_two(birthDateTime.day)}T'
        '${_two(birthDateTime.hour)}:'
        '${_two(birthDateTime.minute)}:'
        '${_two(birthDateTime.second)}'
        '${_formatTimezoneOffset(birthDateTime.timeZoneOffset)}';

    final queryParameters = <String, String>{
      'ayanamsa': ayanamsa.toString(),
      'coordinates': '$latitude,$longitude',
      'datetime': isoString,
    };

    if (language != null && language.isNotEmpty) {
      queryParameters['la'] = language;
    }

    final url = Uri.parse('$_proxyBaseUrl/kundli')
        .replace(queryParameters: queryParameters);

    final response = await http.get(
      url,
    );

    if (response.statusCode != 200) {
      String errorDetails = 'Unknown error';
      try {
        final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
        errorDetails = errorJson['details']?.toString() ?? 
                      errorJson['error']?.toString() ?? 
                      response.body;
      } catch (_) {
        errorDetails = response.body;
      }
      throw Exception(
        'Failed to fetch kundli via proxy '
        '(status ${response.statusCode}): $errorDetails',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded;
  }

  /// Fetches a chart SVG from Prokerala API via the proxy.
  ///
  /// Parameters:
  /// - [birthDateTime]: Birth date and time
  /// - [latitude]: Birth location latitude
  /// - [longitude]: Birth location longitude
  /// - [chartType]: Type of chart (rasi, navamsa, lagna, etc.)
  /// - [chartStyle]: Chart style (north-indian, south-indian, east-indian)
  /// - [ayanamsa]: Ayanamsa value (1=Lahiri, 3=Raman, 5=KP)
  /// - [language]: Optional language code (en, hi, ta, te, ml)
  /// - [upagrahaPosition]: Optional upagraha position (start, middle, end)
  ///
  /// Returns the SVG content as a string.
  static Future<String> fetchChart({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    required String chartType,
    required String chartStyle,
    int ayanamsa = 1,
    String? language,
    String? upagrahaPosition,
  }) async {
    // Prokerala expects an ISO datetime that includes the local timezone offset.
    // Use a strict format without fractional seconds:
    // `YYYY-MM-DDTHH:mm:ss+HH:MM`
    final isoString = '${birthDateTime.year.toString().padLeft(4, '0')}-'
        '${_two(birthDateTime.month)}-'
        '${_two(birthDateTime.day)}T'
        '${_two(birthDateTime.hour)}:'
        '${_two(birthDateTime.minute)}:'
        '${_two(birthDateTime.second)}'
        '${_formatTimezoneOffset(birthDateTime.timeZoneOffset)}';

    final queryParameters = <String, String>{
      'ayanamsa': ayanamsa.toString(),
      'coordinates': '$latitude,$longitude',
      'datetime': isoString,
      'chart_type': chartType,
      'chart_style': chartStyle,
      'format': 'svg',
    };

    if (language != null && language.isNotEmpty) {
      queryParameters['la'] = language;
    }

    if (upagrahaPosition != null && upagrahaPosition.isNotEmpty) {
      queryParameters['upagraha_position'] = upagrahaPosition;
    }

    final url = Uri.parse('$_proxyBaseUrl/charts')
        .replace(queryParameters: queryParameters);

    final response = await http.get(
      url,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch chart via proxy '
        '(status ${response.statusCode}): ${response.body}',
      );
    }

    return response.body;
  }

  /// Fetches planet positions from Prokerala API via the proxy.
  ///
  /// Parameters:
  /// - [birthDateTime]: Birth date and time
  /// - [latitude]: Birth location latitude
  /// - [longitude]: Birth location longitude
  /// - [ayanamsa]: Ayanamsa value (1=Lahiri, 3=Raman, 5=KP)
  /// - [planets]: Optional comma-separated list of planet IDs (e.g., "0,1,100,102")
  ///   If not provided, returns all planets excluding URANUS, NEPTUNE, and PLUTO.
  /// - [language]: Optional language code (en, hi, ta, te, ml)
  ///
  /// Returns the decoded JSON response as a Map.
  static Future<Map<String, dynamic>> fetchPlanetPosition({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    int ayanamsa = 1,
    String? planets,
    String? language,
  }) async {
    // Prokerala expects an ISO datetime that includes the local timezone offset.
    final isoString = '${birthDateTime.year.toString().padLeft(4, '0')}-'
        '${_two(birthDateTime.month)}-'
        '${_two(birthDateTime.day)}T'
        '${_two(birthDateTime.hour)}:'
        '${_two(birthDateTime.minute)}:'
        '${_two(birthDateTime.second)}'
        '${_formatTimezoneOffset(birthDateTime.timeZoneOffset)}';

    final queryParameters = <String, String>{
      'ayanamsa': ayanamsa.toString(),
      'coordinates': '$latitude,$longitude',
      'datetime': isoString,
    };

    if (planets != null && planets.isNotEmpty) {
      queryParameters['planets'] = planets;
    }

    if (language != null && language.isNotEmpty) {
      queryParameters['la'] = language;
    }

    final url = Uri.parse('$_proxyBaseUrl/planet-position')
        .replace(queryParameters: queryParameters);

    final response = await http.get(
      url,
    );

    if (response.statusCode != 200) {
      String errorDetails = 'Unknown error';
      try {
        final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
        errorDetails = errorJson['details']?.toString() ?? 
                      errorJson['error']?.toString() ?? 
                      response.body;
      } catch (_) {
        errorDetails = response.body;
      }
      throw Exception(
        'Failed to fetch planet position via proxy '
        '(status ${response.statusCode}): $errorDetails',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded;
  }

  /// Best-effort conversion from Prokerala kundli response into the app's
  /// `KundaliData` model (houses + planet placements).
  ///
  /// If Prokerala changes fields (or response lacks placements), this returns
  /// houses with empty planet list rather than mock data.
  static KundaliData toKundaliData(Map<String, dynamic> raw) {
    final data = (raw['data'] as Map?)?.cast<String, dynamic>() ?? const {};

    final houses = _extractHouses(data);
    final planets = _extractPlanets(data);

    return KundaliData(houses: houses, planets: planets);
  }

  static List<HouseData> _extractHouses(Map<String, dynamic> data) {
    final zodiacFallback = const [
      'Ar', 'Ta', 'Ge', 'Cn', 'Le', 'Vi', 'Li', 'Sc', 'Sg', 'Cp', 'Aq', 'Pi'
    ];

    final extracted = <HouseData>[];

    dynamic housesJson = data['houses'];
    if (housesJson is! List) {
      housesJson = data['house_details'];
    }
    if (housesJson is List) {
      for (final item in housesJson) {
        if (item is! Map) continue;
        final m = item.cast<String, dynamic>();
        final hn = (m['house'] ?? m['house_number'] ?? m['house_num']);
        final houseNumber = hn is num ? hn.toInt() : int.tryParse('$hn');
        if (houseNumber == null || houseNumber < 1 || houseNumber > 12) continue;

        final sign = _extractSignAbbr(m) ?? zodiacFallback[(houseNumber - 1) % 12];
        extracted.add(HouseData(houseNumber: houseNumber, zodiacSign: sign));
      }
    }

    // Ensure exactly 12 houses.
    if (extracted.length == 12) {
      extracted.sort((a, b) => a.houseNumber.compareTo(b.houseNumber));
      return extracted;
    }

    final byNum = <int, HouseData>{ for (final h in extracted) h.houseNumber: h };
    return List.generate(12, (i) {
      final n = i + 1;
      return byNum[n] ??
          HouseData(houseNumber: n, zodiacSign: zodiacFallback[i % 12]);
    });
  }

  static List<PlanetData> _extractPlanets(Map<String, dynamic> data) {
    // Candidate fields in Prokerala responses vary; try common ones.
    final candidates = <dynamic>[
      data['planet_positions'],
      data['planets'],
      data['planet_details'],
      data['planet_position'],
    ];

    final planets = <PlanetData>[];

    for (final candidate in candidates) {
      if (candidate is! List) continue;
      for (final item in candidate) {
        if (item is! Map) continue;
        final m = item.cast<String, dynamic>();

        final planetName = _extractPlanetAbbr(m);
        if (planetName == null) continue;

        final hn = (m['house'] ?? m['house_number'] ?? m['house_num']);
        final house = hn is num ? hn.toInt() : int.tryParse('$hn');
        if (house == null) continue;

        final sign = _extractSignAbbr(m) ?? '';

        planets.add(
          PlanetData(
            name: planetName,
            house: house.clamp(1, 12),
            sign: sign,
          ),
        );
      }
      if (planets.isNotEmpty) break;
    }

    return planets;
  }

  static String? _extractPlanetAbbr(Map<String, dynamic> m) {
    final rawName = (m['name'] ??
            m['planet'] ??
            m['planet_name'] ??
            (m['planet_details'] is Map ? (m['planet_details'] as Map)['name'] : null) ??
            (m['planet_details'] is Map ? (m['planet_details'] as Map)['vedic_name'] : null))
        ?.toString()
        .trim()
        .toLowerCase();

    if (rawName == null || rawName.isEmpty) return null;

    const map = {
      'sun': 'Su',
      'surya': 'Su',
      'moon': 'Mo',
      'chandra': 'Mo',
      'mars': 'Ma',
      'mangal': 'Ma',
      'mercury': 'Me',
      'buddha': 'Me',
      'jupiter': 'Ju',
      'guru': 'Ju',
      'venus': 'Ve',
      'shukra': 'Ve',
      'saturn': 'Sa',
      'shani': 'Sa',
      'rahu': 'Ra',
      'ketu': 'Ke',
      'uranus': 'Ur',
      'neptune': 'Ne',
      'pluto': 'Pl',
    };

    // If already an abbreviation like "Su".
    if (rawName.length == 2 && rawName[0] == rawName[0].toLowerCase()) {
      // lowercased 2-letter is unlikely; ignore.
    }

    if (rawName.length == 2) {
      // Preserve common two-letter abbreviations if provided.
      final pretty = rawName[0].toUpperCase() + rawName[1];
      return pretty;
    }

    return map[rawName];
  }

  static String? _extractSignAbbr(Map<String, dynamic> m) {
    final rawSign = (m['sign'] ??
            m['rasi'] ??
            m['zodiac_sign'] ??
            (m['sign_details'] is Map ? (m['sign_details'] as Map)['name'] : null))
        ?.toString()
        .trim()
        .toLowerCase();

    if (rawSign == null || rawSign.isEmpty) return null;

    const map = {
      'aries': 'Ar',
      'taurus': 'Ta',
      'gemini': 'Ge',
      'cancer': 'Cn',
      'leo': 'Le',
      'virgo': 'Vi',
      'libra': 'Li',
      'scorpio': 'Sc',
      'sagittarius': 'Sg',
      'capricorn': 'Cp',
      'aquarius': 'Aq',
      'pisces': 'Pi',
      // sometimes already abbreviated
      'ar': 'Ar',
      'ta': 'Ta',
      'ge': 'Ge',
      'cn': 'Cn',
      'le': 'Le',
      'vi': 'Vi',
      'li': 'Li',
      'sc': 'Sc',
      'sg': 'Sg',
      'cp': 'Cp',
      'aq': 'Aq',
      'pi': 'Pi',
    };

    return map[rawSign] ?? (rawSign.length >= 2 ? rawSign.substring(0, 2) : rawSign);
  }
}

