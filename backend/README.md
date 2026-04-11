# Marble POS — Backend Setup

## 1. Install & run

```bash
npm install
npm start          # production
npm run dev        # auto-restart on file changes
```

---

## 2. Fill in .env

### Stripe
1. Go to https://dashboard.stripe.com/apikeys
2. Copy **Secret key** → `STRIPE_SECRET_KEY`
3. Run `stripe listen --forward-to localhost:3000/webhook` → copy the webhook secret → `STRIPE_WEBHOOK_SECRET`

### Supabase
1. Go to your Supabase project → Settings → API
2. Copy **service_role** key (NOT anon key) → `SUPABASE_SERVICE_KEY`

### MTN MoMo (step-by-step)

**Step 1 — Create a developer account**
- Go to https://momodeveloper.mtn.com
- Sign up and log in

**Step 2 — Subscribe to Collections API**
- Go to Products → Collections
- Click Subscribe → choose Sandbox
- Copy your **Primary Key** → `MTN_SUBSCRIPTION_KEY`

**Step 3 — Create an API User**
Run this once in your terminal (replace YOUR_SUBSCRIPTION_KEY):
```bash
curl -X POST https://sandbox.momodeveloper.mtn.com/v1_0/apiuser \
  -H "X-Reference-Id: $(uuidgen)" \
  -H "Ocp-Apim-Subscription-Key: YOUR_SUBSCRIPTION_KEY" \
  -H "Content-Type: application/json" \
  -d '{"providerCallbackHost": "your-backend-domain.com"}'
```
The `X-Reference-Id` you used becomes your `MTN_API_USER`.

**Step 4 — Get the API Key**
```bash
curl -X POST https://sandbox.momodeveloper.mtn.com/v1_0/apiuser/YOUR_API_USER/apikey \
  -H "Ocp-Apim-Subscription-Key: YOUR_SUBSCRIPTION_KEY"
```
Copy `apiKey` from the response → `MTN_API_KEY`

**Step 5 — Set callback URL**
- `MTN_CALLBACK_URL` = your deployed backend URL + `/mtn-callback`
- e.g. `https://marble-backend.onrender.com/mtn-callback`
- For local testing use ngrok: `ngrok http 3000` → copy the https URL

**Step 6 — Go live**
- Change `MTN_ENVIRONMENT=sandbox` → `MTN_ENVIRONMENT=mtnzambia` (or your country code)
- Change `MTN_BASE_URL` to `https://proxy.momoapi.mtn.com`
- Get production credentials from MTN business portal

---

## 3. Supabase RLS policies (run in SQL editor)

```sql
-- Only admins can delete sales
create policy "admin delete sales"
on sales for delete to authenticated
using (
  exists (
    select 1 from profiles
    where id = auth.uid() and role = 'admin'
  )
);

-- Users can only read their own profile
create policy "own profile"
on profiles for select to authenticated
using (id = auth.uid());

-- Only service role can update plan (prevents frontend cheating)
create policy "service role update plan"
on profiles for update to authenticated
using (id = auth.uid())
with check (
  -- users can update their own profile but NOT the plan column
  -- plan is only updated by the backend service role
  plan = (select plan from profiles where id = auth.uid())
);
```

---

## 4. Deploy to production (Render — free tier)

1. Push `backend/` to a GitHub repo
2. Go to https://render.com → New Web Service
3. Connect your repo, set build command: `npm install`, start command: `node server.js`
4. Add all `.env` variables in Render's Environment tab
5. Copy the deployed URL → update `FRONTEND_URL` and `MTN_CALLBACK_URL`
