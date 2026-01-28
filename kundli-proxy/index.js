import express from "express";
import axios from "axios";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PROKERALA_BASE_URL = "https://api.prokerala.com";
const SANDBOX_MODE = String(process.env.PROKERALA_SANDBOX || "").toLowerCase() === "true";

function rewriteDatetimeForSandbox(datetime) {
  // Sandbox mode restriction from Prokerala:
  // "only January 1st is allowed — any time and any year is accepted."
  // So rewrite month/day to 01-01 while preserving year/time/offset.
  //
  // Supports: YYYY-MM-DDTHH:mm:ss(+HH:MM|-HH:MM)
  //           YYYY-MM-DDTHH:mm:ss.SSS(+HH:MM|-HH:MM)
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
    if (SANDBOX_MODE && params.datetime) {
      params.datetime = rewriteDatetimeForSandbox(params.datetime);
    }

    const response = await axios.get(`${PROKERALA_BASE_URL}/v2/astrology/kundli`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
      params,
    });

    res.json(response.data);
  } catch (err) {
    const status = err?.statusCode || err?.response?.status || 500;
    res.status(status).json({
      error: "Failed to fetch kundli",
      details: err?.response?.data || err?.message || String(err),
    });
  }
});

const port = Number(process.env.PORT || 3000);
app.listen(port, () => {
  // Intentionally plain log (no secrets)
  console.log(`Kundli proxy running on http://localhost:${port}`);
});
