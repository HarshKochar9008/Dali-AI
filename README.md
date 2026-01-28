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

### Primary API Used: Prokerala Astrology API (V2)

- **Base URL:** `https://api.prokerala.com`
- **Authentication:** OAuth2 Client Credentials

#### 1. Token Endpoint

- **Endpoint:** `POST /token`
- **URL:** `https://api.prokerala.com/token`
- **Headers:**
  - `Content-Type: application/x-www-form-urlencoded`
- **Body (form fields):**
  - `grant_type`: `"client_credentials"`
  - `client_id`: `<YOUR_CLIENT_ID>`
  - `client_secret`: `<YOUR_CLIENT_SECRET>`

**Sample Request Body (x-www-form-urlencoded):**

```text
grant_type=client_credentials&client_id=<YOUR_CLIENT_ID>&client_secret=<YOUR_CLIENT_SECRET>
```

**Sample Response:**

```json
{
  "access_token": "ya29.1.AADtN_XK16As2ZHlScqOxGtntIlevNcasMSPwGiE3pe5ANZfrmJTcsI3ZtAjv4sDrPDRnQ",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

The `access_token` is then used as a Bearer token for subsequent API calls.

#### 2. Kundli Endpoint (Basic Kundali)

- **Endpoint:** `GET /v2/astrology/kundli`
- **URL:** `https://api.prokerala.com/v2/astrology/kundli`
- **Authentication:** `Authorization: Bearer <ACCESS_TOKEN>`
- **Query Parameters:**
  - `ayanamsa` (number, required)  
    - `1` = Lahiri, `3` = Raman, `5` = KP
  - `coordinates` (string, required)  
    - Latitude and longitude: `"10.214747,78.097626"`
  - `datetime` (string, required)  
    - ISO 8601: `YYYY-MM-DDTHH:MM:SSZ` (URL-encoded when used as a query parameter)
  - `la` (string, optional)  
    - Language: one of `en`, `ta`, `ml`, `hi`

**Sample Request:**

```bash
curl -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "https://api.prokerala.com/v2/astrology/kundli?ayanamsa=1&coordinates=23.1765,75.7885&datetime=2022-03-17T10:50:40Z"
```

**Sample Response (simplified):**

```json
{
  "status": "ok",
  "data": {
    "nakshatra_details": { /* ... */ },
    "mangal_dosha": { /* ... */ },
    "yoga_details": [ /* ... */ ]
  }
}
```

#### 3. Detailed Kundli Endpoint (Advanced)

- **Endpoint:** `GET /v2/astrology/kundli/advanced`
- **URL:** `https://api.prokerala.com/v2/astrology/kundli/advanced`
- **Authentication & query parameters:** Same as `/v2/astrology/kundli`
- **Additional Query Parameters:**
  - `year_length` (number, optional)  
    - `1` = 365.25 days/year (default), `0` = 360 days/year

**Sample Response (simplified):**

```json
{
  "status": "ok",
  "data": {
    "nakshatra_details": { /* ... */ },
    "mangal_dosha": { /* ... */ },
    "yoga_details": [ /* ... */ ],
    "dasha_balance": { /* ... */ },
    "dasha_periods": [ /* ... */ ]
  }
}
```

#### 4. How the App Uses the API

- User inputs (date, time, latitude, longitude) are collected on `InputScreen`.
- These values are combined into a `DateTime` and passed to `ProkeralaApi.fetchKundli(...)`.
- `ProkeralaApi`:
  - Requests an access token from `POST /token`.
  - Calls `GET /v2/astrology/kundli` with the user-provided birth details.
  - Returns the **live JSON response** from Prokerala (no hardcoded data).

> **Important:** For production, the OAuth client ID and secret must **not** be embedded in the mobile app. They should be stored on a secure backend, and the app should call that backend instead of `api.prokerala.com` directly.

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
