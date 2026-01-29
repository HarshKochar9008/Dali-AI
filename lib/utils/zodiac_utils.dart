import '../models/kundali_data.dart';

/// Zodiac sign display names and attributes for home/profile UI.
class ZodiacUtils {
  ZodiacUtils._();

  static const List<String> signNames = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];

  static const Map<String, String> signAbbrToName = {
    'Ar': 'Aries',
    'Ta': 'Taurus',
    'Ge': 'Gemini',
    'Cn': 'Cancer',
    'Le': 'Leo',
    'Vi': 'Virgo',
    'Li': 'Libra',
    'Sc': 'Scorpio',
    'Sg': 'Sagittarius',
    'Cp': 'Capricorn',
    'Aq': 'Aquarius',
    'Pi': 'Pisces',
  };

  static const Map<String, String> signToElement = {
    'Ar': 'Fire',
    'Ta': 'Earth',
    'Ge': 'Air',
    'Cn': 'Water',
    'Le': 'Fire',
    'Vi': 'Earth',
    'Li': 'Air',
    'Sc': 'Water',
    'Sg': 'Fire',
    'Cp': 'Earth',
    'Aq': 'Air',
    'Pi': 'Water',
  };

  static const Map<String, String> signToPolarity = {
    'Ar': 'Masculine',
    'Ta': 'Feminine',
    'Ge': 'Masculine',
    'Cn': 'Feminine',
    'Le': 'Masculine',
    'Vi': 'Feminine',
    'Li': 'Masculine',
    'Sc': 'Feminine',
    'Sg': 'Masculine',
    'Cp': 'Feminine',
    'Aq': 'Masculine',
    'Pi': 'Feminine',
  };

  static const Map<String, String> signToModality = {
    'Ar': 'Cardinal',
    'Ta': 'Fixed',
    'Ge': 'Mutable',
    'Cn': 'Cardinal',
    'Le': 'Fixed',
    'Vi': 'Mutable',
    'Li': 'Cardinal',
    'Sc': 'Fixed',
    'Sg': 'Mutable',
    'Cp': 'Cardinal',
    'Aq': 'Fixed',
    'Pi': 'Mutable',
  };

  /// Sun sign index 0..11 by approximate date ranges (tropical).
  static int _sunSignIndexFromDate(DateTime date) {
    final day = date.day;
    final month = date.month;
    if (month == 3 && day >= 21) return 0;
    if (month == 4 && day <= 19) return 0;
    if (month == 4 && day >= 20) return 1;
    if (month == 5 && day <= 20) return 1;
    if (month == 5 && day >= 21) return 2;
    if (month == 6 && day <= 20) return 2;
    if (month == 6 && day >= 21) return 3;
    if (month == 7 && day <= 22) return 3;
    if (month == 7 && day >= 23) return 4;
    if (month == 8 && day <= 22) return 4;
    if (month == 8 && day >= 23) return 5;
    if (month == 9 && day <= 22) return 5;
    if (month == 9 && day >= 23) return 6;
    if (month == 10 && day <= 22) return 6;
    if (month == 10 && day >= 23) return 7;
    if (month == 11 && day <= 21) return 7;
    if (month == 11 && day >= 22) return 8;
    if (month == 12 && day <= 21) return 8;
    if (month == 12 && day >= 22) return 9;
    if (month == 1 && day <= 19) return 9;
    if (month == 1 && day >= 20) return 10;
    if (month == 2 && day <= 18) return 10;
    if (month == 2 && day >= 19) return 11;
    if (month == 3 && day <= 20) return 11;
    return 0;
  }

  static const List<String> _signAbbrs = [
    'Ar',
    'Ta',
    'Ge',
    'Cn',
    'Le',
    'Vi',
    'Li',
    'Sc',
    'Sg',
    'Cp',
    'Aq',
    'Pi',
  ];

  /// Sun sign name from date of birth (e.g. "Leo").
  static String sunSignNameFromDob(DateTime? dob) {
    if (dob == null) return '—';
    final i = _sunSignIndexFromDate(dob);
    return signNames[i];
  }

  /// Sun sign abbreviation from DOB for consistency with kundali (e.g. "Le").
  static String sunSignAbbrFromDob(DateTime? dob) {
    if (dob == null) return '';
    return _signAbbrs[_sunSignIndexFromDate(dob)];
  }

  static String _formatSignAbbr(String? abbr) {
    if (abbr == null || abbr.isEmpty) return '—';
    return signAbbrToName[abbr] ?? abbr;
  }

  static String element(String? signAbbr) =>
      signToElement[signAbbr ?? ''] ?? '—';
  static String polarity(String? signAbbr) =>
      signToPolarity[signAbbr ?? ''] ?? '—';
  static String modality(String? signAbbr) =>
      signToModality[signAbbr ?? ''] ?? '—';

  static String sunSignFromKundali(KundaliData? k) {
    if (k == null) return '—';
    final list = k.planets.where((p) => p.name == 'Su').toList();
    return list.isEmpty ? '—' : _formatSignAbbr(list.first.sign);
  }

  static String moonSignFromKundali(KundaliData? k) {
    if (k == null) return '—';
    final list = k.planets.where((p) => p.name == 'Mo').toList();
    return list.isEmpty ? '—' : _formatSignAbbr(list.first.sign);
  }

  static String risingSignFromKundali(KundaliData? k) {
    if (k == null) return '—';
    final list = k.houses.where((h) => h.houseNumber == 1).toList();
    return list.isEmpty ? '—' : _formatSignAbbr(list.first.zodiacSign);
  }

  /// Primary sign for display (from kundali sun if available, else from DOB).
  static String primarySignName(KundaliData? kundali, DateTime? dob) {
    if (kundali != null) {
      final name = sunSignFromKundali(kundali);
      if (name != '—') return name;
    }
    return sunSignNameFromDob(dob);
  }

  /// Sign abbreviation for element/polarity/modality (from kundali sun or DOB).
  static String primarySignAbbr(KundaliData? kundali, DateTime? dob) {
    if (kundali != null) {
      final list = kundali.planets.where((p) => p.name == 'Su').toList();
      if (list.isNotEmpty && list.first.sign.isNotEmpty) return list.first.sign;
    }
    return sunSignAbbrFromDob(dob);
  }
}
