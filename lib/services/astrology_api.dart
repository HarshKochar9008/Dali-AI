import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kundali_data.dart';

class AstrologyApi {
  static const String baseUrl = 'https://api.freeastroapi.com';

  static Future<KundaliData> fetchKundaliData({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
  }) async {
    final day = birthDateTime.day;
    final month = birthDateTime.month;
    final year = birthDateTime.year;
    final hour = birthDateTime.hour;
    final minute = birthDateTime.minute;

    final timezoneOffset = birthDateTime.timeZoneOffset.inHours.toDouble();
    
    final url = Uri.parse('$baseUrl/natal');
    
    final requestBody = {
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'minute': minute,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezoneOffset,
      'house_system': 'placidus',
    };
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseKundaliResponse(data);
      } else {
        return _getMockData();
      }
    } catch (e) {
      return _getMockData();
    }
  }

  static KundaliData _parseKundaliResponse(Map<String, dynamic> data) {
    final houses = <HouseData>[];
    final planets = <PlanetData>[];

    final zodiacSigns = [
      'Ar', 'Ta', 'Ge', 'Cn', 'Le', 'Vi',
      'Li', 'Sc', 'Sg', 'Cp', 'Aq', 'Pi'
    ];

    if (data['houses'] != null && data['houses'] is List) {
      final housesList = data['houses'] as List;
      for (var i = 0; i < 12; i++) {
        String sign = '';
        if (i < housesList.length && housesList[i] is Map) {
          final houseData = housesList[i] as Map<String, dynamic>;
          final signIndex = (houseData['sign'] ?? 0) as int;
          sign = zodiacSigns[signIndex % 12];
        } else {
          sign = zodiacSigns[i % 12];
        }
        houses.add(HouseData(
          houseNumber: i + 1,
          zodiacSign: sign,
        ));
      }
    } else {
      for (var i = 0; i < 12; i++) {
        houses.add(HouseData(
          houseNumber: i + 1,
          zodiacSign: zodiacSigns[i % 12],
        ));
      }
    }

    final planetMap = {
      'sun': 'Su',
      'moon': 'Mo',
      'mars': 'Ma',
      'mercury': 'Me',
      'jupiter': 'Ju',
      'venus': 'Ve',
      'saturn': 'Sa',
      'rahu': 'Ra',
      'ketu': 'Ke',
      'uranus': 'Ur',
      'neptune': 'Ne',
      'pluto': 'Pl',
    };

    if (data['planets'] != null && data['planets'] is List) {
      final planetsList = data['planets'] as List;
      for (var planet in planetsList) {
        if (planet is Map<String, dynamic>) {
          final name = (planet['name'] ?? '').toString().toLowerCase();
          final planetAbbr = planetMap[name];
          if (planetAbbr != null) {
            final house = (planet['house'] ?? 1) as int;
            final signIndex = (planet['sign'] ?? 0) as int;
            final sign = zodiacSigns[signIndex % 12];
            planets.add(PlanetData(
              name: planetAbbr,
              house: house.clamp(1, 12),
              sign: sign,
            ));
          }
        }
      }
    }

    while (houses.length < 12) {
      houses.add(HouseData(
        houseNumber: houses.length + 1,
        zodiacSign: zodiacSigns[houses.length % 12],
      ));
    }

    return KundaliData(houses: houses, planets: planets);
  }

  static KundaliData _getMockData() {
    final zodiacSigns = [
      'Ar', 'Ta', 'Ge', 'Cn', 'Le', 'Vi',
      'Li', 'Sc', 'Sg', 'Cp', 'Aq', 'Pi'
    ];

    final houses = List.generate(12, (index) => HouseData(
      houseNumber: index + 1,
      zodiacSign: zodiacSigns[index],
    ));

    final planets = [
      PlanetData(name: 'Su', house: 1, sign: 'Ar'),
      PlanetData(name: 'Mo', house: 2, sign: 'Ta'),
      PlanetData(name: 'Ma', house: 3, sign: 'Ge'),
      PlanetData(name: 'Me', house: 4, sign: 'Cn'),
      PlanetData(name: 'Ju', house: 5, sign: 'Le'),
      PlanetData(name: 'Ve', house: 6, sign: 'Vi'),
      PlanetData(name: 'Sa', house: 7, sign: 'Li'),
      PlanetData(name: 'Ra', house: 8, sign: 'Sc'),
      PlanetData(name: 'Ke', house: 9, sign: 'Sg'),
    ];

    return KundaliData(houses: houses, planets: planets);
  }
}
