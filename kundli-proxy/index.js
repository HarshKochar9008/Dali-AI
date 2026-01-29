import express from "express";
import axios from "axios";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PROKERALA_BASE_URL = "https://api.prokerala.com";
const SANDBOX_MODE = String(process.env.SANDBOX_MODE || process.env.PROKERALA_SANDBOX || "").toLowerCase() === "true";

function rewriteDatetimeForSandbox(datetime) {

  if (typeof datetime !== "string") return datetime;
  const m = datetime.match(
    /^(\d{4})-(\d{2})-(\d{2})(T\d{2}:\d{2}:\d{2}(?:\.\d{1,3})?)(Z|[+-]\d{2}:\d{2})?$/
  );
  if (!m) return datetime;
  const year = m[1];
  const timePart = m[4];
  const tz = m[5] || "";
  return `${year}-01-01${timePart}${tz}`;
}

let cachedToken = null;
let tokenExpiry = 0;

async function getAccessToken() {
  if (cachedToken && Date.now() < tokenExpiry) {
    return cachedToken;
  }

  const clientId = process.env.PROKERALA_CLIENT_ID;
  const clientSecret = process.env.PROKERALA_CLIENT_SECRET;

  if (!clientId || !clientSecret) {
    const msg =
      "Missing PROKERALA_CLIENT_ID / PROKERALA_CLIENT_SECRET in environment";
    const err = new Error(msg);
    err.statusCode = 500;
    throw err;
  }

  const res = await axios.post(
    `${PROKERALA_BASE_URL}/token`,
    new URLSearchParams({
      grant_type: "client_credentials",
      client_id: clientId,
      client_secret: clientSecret,
    }),
    {
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
    }
  );

  cachedToken = res.data.access_token;
  tokenExpiry = Date.now() + (res.data.expires_in - 60) * 1000;

  return cachedToken;
}

app.get("/kundli", async (req, res) => {
  try {
    const token = await getAccessToken();

    const params = { ...req.query };
    
    // Validate required parameters
    if (!params.ayanamsa) {
      return res.status(400).json({
        error: "Missing required parameter: ayanamsa",
      });
    }
    if (!params.coordinates) {
      return res.status(400).json({
        error: "Missing required parameter: coordinates",
      });
    }
    if (!params.datetime) {
      return res.status(400).json({
        error: "Missing required parameter: datetime",
      });
    }

    // Validate coordinates format
    const coordsMatch = params.coordinates.match(/^(-?\d+\.?\d*),(-?\d+\.?\d*)$/);
    if (!coordsMatch) {
      return res.status(400).json({
        error: "Invalid coordinates format. Expected: latitude,longitude",
        received: params.coordinates,
      });
    }
    const lat = parseFloat(coordsMatch[1]);
    const lon = parseFloat(coordsMatch[2]);
    if (isNaN(lat) || isNaN(lon) || lat < -90 || lat > 90 || lon < -180 || lon > 180) {
      return res.status(400).json({
        error: "Invalid coordinates. Latitude must be -90 to 90, longitude must be -180 to 180",
        received: params.coordinates,
      });
    }

    // Validate datetime format (ISO 8601 with timezone)
    const datetimeRegex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,3})?(Z|[+-]\d{2}:\d{2})$/;
    if (!datetimeRegex.test(params.datetime)) {
      return res.status(400).json({
        error: "Invalid datetime format. Expected ISO 8601 format: YYYY-MM-DDTHH:mm:ss+HH:MM or YYYY-MM-DDTHH:mm:ssZ",
        received: params.datetime,
      });
    }

    if (SANDBOX_MODE && params.datetime) {
      params.datetime = rewriteDatetimeForSandbox(params.datetime);
    }

    console.log(`[Kundli] Request params:`, {
      ayanamsa: params.ayanamsa,
      coordinates: params.coordinates,
      datetime: params.datetime,
      sandboxMode: SANDBOX_MODE,
    });

    const response = await axios.get(`${PROKERALA_BASE_URL}/v2/astrology/kundli`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
      params,
    });

    res.json(response.data);
  } catch (err) {
    const status = err?.statusCode || err?.response?.status || 500;
    const errorData = err?.response?.data;
    const errorMessage = err?.message || String(err);
    
    console.error(`[Kundli] Error (${status}):`, {
      message: errorMessage,
      data: errorData,
      requestParams: req.query,
    });

    res.status(status).json({
      error: "Failed to fetch kundli",
      details: errorData || errorMessage,
      statusCode: status,
    });
  }
});

app.get("/charts", async (req, res) => {
  try {
    const token = await getAccessToken();

    const params = { ...req.query };
    if (SANDBOX_MODE && params.datetime) {
      params.datetime = rewriteDatetimeForSandbox(params.datetime);
    }

    const response = await axios.get(`${PROKERALA_BASE_URL}/v2/astrology/chart`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
      params,
      responseType: 'text', // SVG is returned as text
    });

    res.setHeader('Content-Type', 'image/svg+xml');
    res.send(response.data);
  } catch (err) {
    const status = err?.statusCode || err?.response?.status || 500;
    res.status(status).json({
      error: "Failed to fetch chart",
      details: err?.response?.data || err?.message || String(err),
    });
  }
});

app.get("/planet-position", async (req, res) => {
  try {
    const token = await getAccessToken();

    const params = { ...req.query };
    
    // Validate required parameters
    if (!params.ayanamsa) {
      return res.status(400).json({
        error: "Missing required parameter: ayanamsa",
      });
    }
    if (!params.coordinates) {
      return res.status(400).json({
        error: "Missing required parameter: coordinates",
      });
    }
    if (!params.datetime) {
      return res.status(400).json({
        error: "Missing required parameter: datetime",
      });
    }

    // Validate coordinates format
    const coordsMatch = params.coordinates.match(/^(-?\d+\.?\d*),(-?\d+\.?\d*)$/);
    if (!coordsMatch) {
      return res.status(400).json({
        error: "Invalid coordinates format. Expected: latitude,longitude",
        received: params.coordinates,
      });
    }
    const lat = parseFloat(coordsMatch[1]);
    const lon = parseFloat(coordsMatch[2]);
    if (isNaN(lat) || isNaN(lon) || lat < -90 || lat > 90 || lon < -180 || lon > 180) {
      return res.status(400).json({
        error: "Invalid coordinates. Latitude must be -90 to 90, longitude must be -180 to 180",
        received: params.coordinates,
      });
    }

    // Validate datetime format (ISO 8601 with timezone)
    const datetimeRegex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,3})?(Z|[+-]\d{2}:\d{2})$/;
    if (!datetimeRegex.test(params.datetime)) {
      return res.status(400).json({
        error: "Invalid datetime format. Expected ISO 8601 format: YYYY-MM-DDTHH:mm:ss+HH:MM or YYYY-MM-DDTHH:mm:ssZ",
        received: params.datetime,
      });
    }

    if (SANDBOX_MODE && params.datetime) {
      params.datetime = rewriteDatetimeForSandbox(params.datetime);
    }

    console.log(`[Planet Position] Request params:`, {
      ayanamsa: params.ayanamsa,
      coordinates: params.coordinates,
      datetime: params.datetime,
      planets: params.planets,
      la: params.la,
      sandboxMode: SANDBOX_MODE,
    });

    const response = await axios.get(`${PROKERALA_BASE_URL}/v2/astrology/planet-position`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
      params,
    });

    res.json(response.data);
  } catch (err) {
    const status = err?.statusCode || err?.response?.status || 500;
    const errorData = err?.response?.data;
    const errorMessage = err?.message || String(err);
    
    console.error(`[Planet Position] Error (${status}):`, {
      message: errorMessage,
      data: errorData,
      requestParams: req.query,
    });

    res.status(status).json({
      error: "Failed to fetch planet position",
      details: errorData || errorMessage,
      statusCode: status,
    });
  }
});

const port = Number(process.env.PORT || 3000);
app.listen(port, () => {
  // Intentionally plain log (no secrets)
  console.log(`Kundli proxy running on http://localhost:${port}`);
});
