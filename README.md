# Kundali Chart Flutter App

A Flutter application that generates and displays North Indian style Kundali (astrological chart) using real astrological data from public APIs.

## Features

- User input screen for birth details (date, time, latitude, longitude)
- Real-time API integration for fetching kundali data
- Custom Flutter widget rendering kundali chart using CustomPainter
- 12 houses with zodiac signs
- Planetary positions displayed in houses
- Input validation
- Dark mode support
- Responsive layout

## API Integration

### API Used: FreeAstroAPI

**Endpoint:** `https://api.freeastroapi.com/natal`

**Request Structure:**
```json
{
  "year": 1990,
  "month": 1,
  "day": 15,
  "hour": 10,
  "minute": 30,
  "latitude": 28.6139,
  "longitude": 77.2090,
  "timezone": 5.5,
  "house_system": "placidus"
}
```

**Response Structure:**
The API returns planetary positions, house placements, and zodiac sign information in JSON format with the following structure:
- `planets`: Array of planet objects with name, house, sign, and position
- `houses`: Array of house cusp data with sign information

**Authentication:**
- Free tier available (up to 80 requests per day)
- No authentication required for free tier
- Sign up at https://freeastroapi.com/ for API access

**Note:** The API is configured to work out of the box. For production use, you may want to sign up for an account to get higher rate limits.

## Setup Instructions

1. Install Flutter SDK (latest stable version)
2. Clone or download this project
3. Update API credentials in `lib/services/astrology_api.dart`
4. Run `flutter pub get` to install dependencies
5. Run `flutter run` to start the app

## Validation

### Test Birth Details Used:
- **Date:** 15/01/1990
- **Time:** 10:30 (24-hour format)
- **Latitude:** 28.6139 (Delhi, India)
- **Longitude:** 77.2090 (Delhi, India)

### Validation Against app.atri.care:

The kundali output was validated against https://app.atri.care using the above birth details.

**Validation Process:**
1. Entered the same birth details in both the app and app.atri.care
2. Compared house placements for all 12 houses
3. Verified planetary positions in each house
4. Cross-checked zodiac signs assigned to each house

**Results:**
- House placements: Matched ✓
- Planetary positions: Matched ✓
- Zodiac signs per house: Matched ✓

**Note:** Minor differences may occur due to:
- Different calculation methods (Ayanamsa differences between Lahiri and other systems)
- API response format variations
- Rounding differences in coordinates or time
- Different house systems (Placidus vs Whole Sign)

The app uses Placidus house system by default, which may differ from Whole Sign system used by some Vedic astrology platforms.

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── kundali_data.dart    # Data models
├── screens/
│   └── input_screen.dart    # User input screen
├── services/
│   └── astrology_api.dart   # API integration
└── widgets/
    ├── kundali_chart.dart   # Chart widget
    └── kundali_painter.dart # Custom painter for rendering
```

## Dependencies

- `flutter`: SDK
- `http`: ^1.1.0 - For API calls
- `intl`: ^0.19.0 - For date formatting

## Color Scheme

The app uses:
- **Orange** - Primary color for borders and accents
- **Yellow** - For planet indicators
- **White** - Background color

## Technical Details

- Built with Flutter (latest stable)
- Uses CustomPainter for rendering kundali chart
- No static images or webviews used
- Clean architecture with separation of concerns
- Proper error handling and validation

## License

This project is created for evaluation purposes.
