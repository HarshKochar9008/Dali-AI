const functions = require("firebase-functions");
const axios = require("axios");

const PROKERALA_BASE_URL = "https://api.prokerala.com";

// Uses environment variables (set in functions/.env or Firebase Console).
// See: https://firebase.google.com/docs/functions/config-env
const getConfig = () => ({
  clientId: process.env.PROKERALA_CLIENT_ID,
  clientSecret: process.env.PROKERALA_CLIENT_SECRET,
  sandboxMode: (process.env.SANDBOX_MODE || process.env.PROKERALA_SANDBOX || "true").toLowerCase() === "true",
});

let cachedToken = null;
let tokenExpiry = 0;

async function getAccessToken() {
  if (cachedToken && Date.now() < tokenExpiry) {
    return cachedToken;
  }

  const {clientId, clientSecret} = getConfig();

  if (!clientId || !clientSecret) {
    throw new functions.https.HttpsError(
        "failed-precondition",
        "Missing Prokerala credentials",
    );
  }

  const res = await axios.post(
      `${PROKERALA_BASE_URL}/token`,
      new URLSearchParams({
        grant_type: "client_credentials",
        client_id: clientId,
        client_secret: clientSecret,
      }),
      {
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
      },
  );

  cachedToken = res.data.access_token;
  tokenExpiry = Date.now() + (res.data.expires_in - 60) * 1000;

  return cachedToken;
}

function rewriteDatetimeForSandbox(datetime) {
  if (typeof datetime !== "string") return datetime;
  const m = datetime.match(
      /^(\d{4})-(\d{2})-(\d{2})(T\d{2}:\d{2}:\d{2}(?:\.\d{1,3})?)(Z|[+-]\d{2}:\d{2})?$/,
  );
  if (!m) return datetime;
  const year = m[1];
  const timePart = m[4];
  const tz = m[5] || "";
  return `${year}-01-01${timePart}${tz}`;
}

exports.kundli = functions.https.onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, POST");
  res.set("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  try {
    const token = await getAccessToken();
    const params = {...req.query};

    const {sandboxMode} = getConfig();
    if (sandboxMode && params.datetime) {
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
    const status = err?.response?.status || 500;
    res.status(status).json({
      error: "Failed to fetch kundli",
      details: err?.response?.data || err?.message || String(err),
    });
  }
});

exports.planetPosition = functions.https.onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, POST");
  res.set("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  try {
    const token = await getAccessToken();
    const params = {...req.query};

    const {sandboxMode} = getConfig();
    if (sandboxMode && params.datetime) {
      params.datetime = rewriteDatetimeForSandbox(params.datetime);
    }

    const response = await axios.get(`${PROKERALA_BASE_URL}/v2/astrology/planet-position`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
      params,
    });

    res.json(response.data);
  } catch (err) {
    const status = err?.response?.status || 500;
    res.status(status).json({
      error: "Failed to fetch planet position",
      details: err?.response?.data || err?.message || String(err),
    });
  }
});
