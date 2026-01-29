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

1. Install Flutter SDK (latest stable version).
2. Clone or download this project.
3. **API credentials (Prokerala):** The app talks to a small Node proxy (`kundli-proxy/`) that holds your Prokerala OAuth credentials.  
   - In `kundli-proxy/`, create a `.env` file with:
     - `PROKERALA_CLIENT_ID` — from your Prokerala free trial account
     - `PROKERALA_CLIENT_SECRET`
   - Start the proxy: `cd kundli-proxy && npm install && node index.js` (default port 3000).
4. **Flutter:** Run `flutter pub get`, then `flutter run`.  
   - For Android emulator, point the app at the proxy with:  
     `flutter run --dart-define=KUNDLI_PROXY_BASE_URL=http://10.0.2.2:3000`  
   - For Chrome/desktop: `flutter run -d chrome --dart-define=KUNDLI_PROXY_BASE_URL=http://localhost:3000`
5. Enter birth details on the input screen and tap **Generate** to fetch kundali data and view the custom-drawn North Indian chart.

## Validation (vs app.atri.care)

**Birth details used for validation:**
- **Date of Birth:** 15/01/1990 (DD/MM/YYYY)
- **Time of Birth:** 10:30 (24-hour format)
- **Latitude:** 28.6139 (decimal, Delhi, India)
- **Longitude:** 77.2090 (decimal, Delhi, India)

**Validation process:**  
The **custom-drawn North Indian Kundali** (CustomPainter) output was compared with https://app.atri.care using the same birth details.

1. Entered the above details in this app and in app.atri.care.
2. Compared house placements for all 12 houses.
3. Verified planetary positions (Su, Mo, Ma, Me, Ju, Ve, Sa, Ra, Ke) in each house.
4. Cross-checked zodiac signs per house.

**Result:**  
- House placements: **Matched** ✓  
- Planetary positions: **Matched** ✓  
- Zodiac signs per house: **Matched** ✓  

**Note on differences:**  
Minor differences can occur due to Ayanamsa (e.g. Lahiri vs Raman), house system (Placidus vs Whole Sign), or rounding of time/coordinates. This app uses Prokerala API (Lahiri, Placidus). If you see a small mismatch, note the house system and Ayanamsa used on app.atri.care for comparison.

## Project Structure

```
lib/
├── main.dart                    # App entry point, theme (dark/light)
├── models/
│   ├── kundali_data.dart        # KundaliData, HouseData, PlanetData
│   ├── planet_position.dart     # PlanetPositionResult, SignDetails, etc.
│   ├── prokerala_kundli_summary.dart
│   └── user_profile.dart
├── screens/
│   ├── input_screen.dart        # User input (DOB, time, lat, long)
│   ├── chart_display_screen.dart # Chart view + summary + planet details
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   ├── start_screen.dart
│   └── ...
├── services/
│   ├── prokerala_api.dart       # API calls via kundli-proxy
│   └── storage_service.dart
└── widgets/
    ├── kundali_chart.dart       # Custom Kundali widget (wraps painter)
    ├── kundali_painter.dart     # CustomPainter — 12 houses, signs, planets
    ├── chart_selector_widget.dart
    └── prokerala_chart_widget.dart  # Optional reference (API SVG)
kundli-proxy/                    # Node proxy for Prokerala OAuth + endpoints
└── index.js
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
