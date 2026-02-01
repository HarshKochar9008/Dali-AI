# Kundli Proxy (free backend for the live app)

This Node/Express proxy holds your Prokerala API credentials and forwards requests so the Flutter app never exposes secrets. **Firebase Cloud Functions require a paid (Blaze) plan**, so for a free backend use **Render.com** below.

## Local development

```bash
cp .env.example .env   # then edit .env with your Prokerala credentials
npm install
npm start
```

Runs at `http://localhost:3000`. Point the Flutter app at this URL when running locally.

## Deploy for free on Render.com

1. Sign up at [render.com](https://render.com) (free).
2. **New → Web Service**.
3. Connect your GitHub repo (the repo that contains this `kundli-proxy` folder).
4. Settings:
   - **Root Directory:** `kundli-proxy`
   - **Runtime:** Node
   - **Build Command:** `npm install`
   - **Start Command:** `node index.js`
5. **Environment** tab: add
   - `PROKERALA_CLIENT_ID` = your Prokerala client ID  
   - `PROKERALA_CLIENT_SECRET` = your Prokerala client secret  
   - `SANDBOX_MODE` = `true`
6. Create Web Service. Render will give you a URL like `https://kundli-proxy-xxxx.onrender.com`.

**Use this URL in production:**

- In GitHub: repo **Settings → Secrets and variables → Actions** → New repository secret:  
  `KUNDLI_PROXY_BASE_URL` = `https://kundli-proxy-xxxx.onrender.com` (your Render URL).
- Re-run the “Deploy to Firebase Hosting” workflow (or push to `main`). The web app build will use this URL so the live site at https://mistyai5454.web.app uses your free Render backend.

**Note:** Render’s free tier spins down after ~15 minutes of no traffic; the first request after that may take 30–60 seconds (cold start).
