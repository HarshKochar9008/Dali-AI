class KundaliData {
  final List<HouseData> houses;
  final List<PlanetData> planets;

  KundaliData({
    required this.houses,
    required this.planets,
  });

  factory KundaliData.fromJson(Map<String, dynamic> json) {
    final houses = <HouseData>[];
    final planets = <PlanetData>[];

    if (json['houses'] != null) {
      for (var i = 0; i < json['houses'].length; i++) {
        houses.add(HouseData(
          houseNumber: i + 1,
          zodiacSign: json['houses'][i]['sign'] ?? '',
        ));
      }
    }

    if (json['planets'] != null) {
      final planetsJson = json['planets'] as Map<String, dynamic>;
      planetsJson.forEach((key, value) {
        planets.add(PlanetData(
          name: key,
          house: value['house'] ?? 1,
          sign: value['sign'] ?? '',
        ));
      });
    }

    return KundaliData(houses: houses, planets: planets);
  }
}

class HouseData {
  final int houseNumber;
  final String zodiacSign;

  HouseData({
    required this.houseNumber,
    required this.zodiacSign,
  });
}

class PlanetData {
  final String name;
  final int house;
  final String sign;

  PlanetData({
    required this.name,
    required this.house,
    required this.sign,
  });
}
