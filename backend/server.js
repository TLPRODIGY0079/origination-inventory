require('dotenv').config();
const express  = require('express');
const cors     = require('cors');
const axios    = require('axios');
const { v4: uuidv4 } = require('uuid');
const stripe   = require('stripe')(process.env.STRIPE_SECRET_KEY);
const { createClient } = require('@supabase/supabase-js');

const app = express();
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY   // service-role — bypasses RLS safely on backend
);

// ── CORS ──────────────────────────────────────────────────────────────────────
app.use(cors({ origin: process.env.FRONTEND_URL }));

// ── Raw body for Stripe webhook (MUST come before express.json) ───────────────
app.post('/webhook', express.raw({ type: 'application/json' }), handleStripeWebhook);

// ── JSON body for everything else ─────────────────────────────────────────────
app.use(express.json());


// =============================================================================
// MTN MoMo — token cache (access tokens expire after 1 hour)
// =============================================================================
let _mtnToken = null;
let _mtnTokenExpiry = 0;

async function getMtnToken() {
  if (_mtnToken && Date.now() < _mtnTokenExpiry) return _mtnToken;

  const credentials = Buffer.from(
    `${process.env.MTN_API_USER}:${process.env.MTN_API_KEY}`
  ).toString('base64');

  const { data } = await axios.post(
    `${process.env.MTN_BASE_URL}/collection/token/`,
    {},
    {
      headers: {
        Authorization: `Basic ${credentials}`,
        'Ocp-Apim-Subscription-Key': process.env.MTN_SUBSCRIPTION_KEY
      }
    }
  );

  _mtnToken = data.access_token;
  _mtnTokenExpiry = Date.now() + (data.expires_in - 60) * 1000; // refresh 1 min early
  return _mtnToken;
}


// =============================================================================
// POST /mtn-initiate
// Body: { userId, phone, amount, plan }
// Sends a payment prompt to the user's MTN MoMo phone
// =============================================================================
app.post('/mtn-initiate', async (req, res) => {
  const { userId, phone, amount, plan } = req.body;
  if (!userId || !phone || !amount) {
    return res.status(400).json({ error: 'userId, phone and amount are required' });
  }

  const referenceId = uuidv4(); // unique per transaction

  try {
    const token = await getMtnToken();

    await axios.post(
      `${process.env.MTN_BASE_URL}/collection/v1_0/requesttopay`,
      {
        amount: String(amount),
        currency: 'ZMW',
        externalId: userId,           // your internal reference
        payer: {
          partyIdType: 'MSISDN',
          partyId: phone.replace(/\D/g, '') // digits only e.g. 260971234567
        },
        payerMessage: 'Marble POS — Pro Plan subscription',
        payeeNote:    `Upgrade to ${plan || 'pro'} plan`
      },
      {
        headers: {
          Authorization:               `Bearer ${token}`,
          'X-Reference-Id':            referenceId,
          'X-Target-Environment':      process.env.MTN_ENVIRONMENT,
          'X-Callback-Url':            process.env.MTN_CALLBACK_URL,
          'Ocp-Apim-Subscription-Key': process.env.MTN_SUBSCRIPTION_KEY,
          'Content-Type':              'application/json'
        }
      }
    );

    // Store referenceId so /mtn-callback or /mtn-status can verify it
    console.log(`MTN MoMo initiated: referenceId=${referenceId} phone=${phone} amount=K${amount}`);
    res.json({ referenceId, message: 'Payment prompt sent — check your phone' });

  } catch (err) {
    const detail = err.response?.data || err.message;
    console.error('MTN initiate error:', detail);
    res.status(500).json({ error: 'Failed to initiate MTN payment', detail });
  }
});


// =============================================================================
// GET /mtn-status/:referenceId
// Polls MTN for the payment status of a given referenceId
// =============================================================================
app.get('/mtn-status/:referenceId', async (req, res) => {
  const { referenceId } = req.params;

  try {
    const token = await getMtnToken();

    const { data } = await axios.get(
      `${process.env.MTN_BASE_URL}/collection/v1_0/requesttopay/${referenceId}`,
      {
        headers: {
          Authorization:               `Bearer ${token}`,
          'X-Target-Environment':      process.env.MTN_ENVIRONMENT,
          'Ocp-Apim-Subscription-Key': process.env.MTN_SUBSCRIPTION_KEY
        }
      }
    );

    // data.status: PENDING | SUCCESSFUL | FAILED
    res.json({ status: data.status, data });

  } catch (err) {
    const detail = err.response?.data || err.message;
    console.error('MTN status error:', detail);
    res.status(500).json({ error: 'Failed to check MTN payment status', detail });
  }
});


// =============================================================================
// POST /mtn-callback
// MTN calls this URL automatically when payment is approved or fails
// (set MTN_CALLBACK_URL in .env to your deployed backend URL + /mtn-callback)
// =============================================================================
app.post('/mtn-callback', async (req, res) => {
  const { externalId, status, financialTransactionId } = req.body;

  console.log('MTN callback received:', req.body);

  if (status === 'SUCCESSFUL' && externalId) {
    // externalId = userId we passed in /mtn-initiate
    const { error } = await supabase
      .from('profiles')
      .update({ plan: 'pro' })
      .eq('id', externalId);

    if (error) console.error('Supabase update failed:', error.message);
    else console.log(`✓ MTN callback — plan=pro for user ${externalId} (txn: ${financialTransactionId})`);
  }

  res.sendStatus(200); // always 200 so MTN doesn't retry
});


// =============================================================================
// POST /create-checkout-session  (Stripe card payments)
// Body: { userId, email, plan }
// =============================================================================
app.post('/create-checkout-session', async (req, res) => {
  const { userId, email, plan = 'pro' } = req.body;
  if (!userId || !email) return res.status(400).json({ error: 'userId and email required' });

  const PRICES = {
    pro:        { amount: 29900, name: 'Marble POS — Pro Plan',        interval: 'month' },
    enterprise: { amount: 79900, name: 'Marble POS — Enterprise Plan', interval: 'month' }
  };
  const p = PRICES[plan] || PRICES.pro;

  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      mode: 'subscription',
      customer_email: email,
      metadata: { userId, plan },
      line_items: [{
        price_data: {
          currency: 'zmw',
          product_data: { name: p.name },
          recurring: { interval: p.interval },
          unit_amount: p.amount
        },
        quantity: 1
      }],
      success_url: `${process.env.FRONTEND_URL}/index.html?payment=success`,
      cancel_url:  `${process.env.FRONTEND_URL}/payment.html?cancelled=1`
    });

    res.json({ url: session.url });
  } catch (err) {
    console.error('Stripe error:', err.message);
    res.status(500).json({ error: err.message });
  }
});


// =============================================================================
// POST /webhook  (Stripe calls this after card payment — raw body required)
// =============================================================================
async function handleStripeWebhook(req, res) {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
  } catch (err) {
    console.error('Webhook signature failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    const { userId, plan } = session.metadata || {};
    if (userId && plan) {
      const { error } = await supabase.from('profiles').update({ plan }).eq('id', userId);
      if (error) console.error('Supabase update failed:', error.message);
      else console.log(`✓ Stripe webhook — plan="${plan}" for user ${userId}`);
    }
  }

  if (event.type === 'customer.subscription.deleted') {
    // Downgrade to free when subscription is cancelled
    const email = event.data.object.customer_email;
    if (email) {
      // Look up user by email via auth.users (service role required)
      const { data: users } = await supabase.auth.admin.listUsers();
      const user = users?.users?.find(u => u.email === email);
      if (user) {
        await supabase.from('profiles').update({ plan: 'free' }).eq('id', user.id);
        console.log(`✓ Subscription cancelled — plan=free for ${email}`);
      }
    }
  }

  res.sendStatus(200);
}


// =============================================================================
// POST /invite-staff
// Body: { email: string, role: string, business_id: string }
// Invites a new staff member via Supabase auth and upserts their profile row
// =============================================================================
app.post('/invite-staff', async (req, res) => {
  const { email, role, business_id } = req.body;

  if (!email || !role || !business_id) {
    return res.status(400).json({ error: 'email, role, and business_id are required' });
  }

  try {
    // Invite user via Supabase auth admin API (requires service-role key)
    const { data: inviteData, error: inviteError } = await supabase.auth.admin.inviteUserByEmail(email);

    if (inviteError) {
      // Supabase returns a specific error when the user already exists
      if (inviteError.message && inviteError.message.toLowerCase().includes('already')) {
        return res.status(409).json({ error: 'A user with this email already exists' });
      }
      console.error('Invite error:', inviteError);
      return res.status(500).json({ error: inviteError.message });
    }

    const userId = inviteData?.user?.id;
    if (!userId) {
      return res.status(500).json({ error: 'Failed to retrieve invited user ID' });
    }

    // Upsert a profiles row with the given role and business_id
    const { error: profileError } = await supabase
      .from('profiles')
      .upsert({ id: userId, role, business_id, plan: 'free', onboarding_completed: false });

    if (profileError) {
      console.error('Profile upsert error:', profileError);
      return res.status(500).json({ error: profileError.message });
    }

    console.log(`✓ Staff invited: ${email} as ${role} for business ${business_id}`);
    res.json({ ok: true });

  } catch (err) {
    console.error('Invite staff error:', err.message);
    res.status(500).json({ error: err.message });
  }
});


// =============================================================================


// =============================================================================
// GET /check-subscription
// Validates the calling user's business subscription status
// =============================================================================
app.get('/check-subscription', async (req, res) => {
  const token = (req.headers.authorization || '').replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'No token' });

  const { data: { user }, error: authErr } = await supabase.auth.getUser(token);
  if (authErr || !user) return res.status(401).json({ error: 'Invalid token' });

  const { data: profile } = await supabase.from('profiles').select('business_id').eq('id', user.id).single();
  if (!profile) return res.status(404).json({ error: 'Profile not found' });

  const { data: business } = await supabase.from('businesses').select('subscription_status, expires_at').eq('id', profile.business_id).single();
  if (!business) return res.json({ active: true }); // no businesses table = allow access

  const active = business.subscription_status === 'active' && new Date(business.expires_at) > new Date();
  res.json({ active, subscription_status: business.subscription_status, expires_at: business.expires_at });
});


// =============================================================================
// POST /send-weekly-report
// Sends a weekly sales summary email via Resend to the business owner
// Body: { business_id } — called by a cron job (e.g. every Monday 8am)
// =============================================================================
app.post('/send-weekly-report', async (req, res) => {
  const { business_id } = req.body;
  if (!business_id) return res.status(400).json({ error: 'business_id required' });

  // Verify request comes from internal cron (simple shared secret)
  const secret = req.headers['x-cron-secret'];
  if (secret !== process.env.CRON_SECRET) return res.status(401).json({ error: 'Unauthorized' });

  try {
    // Get business owner email
    const { data: business } = await supabase.from('businesses').select('name').eq('id', business_id).single();
    const { data: owner } = await supabase.from('profiles').select('full_name, id').eq('business_id', business_id).eq('role', 'admin').single();
    const { data: authUser } = await supabase.auth.admin.getUserById(owner.id);
    const ownerEmail = authUser?.user?.email;
    if (!ownerEmail) return res.status(404).json({ error: 'Owner email not found' });

    // Get last 7 days of sales
    const weekAgo = new Date(); weekAgo.setDate(weekAgo.getDate() - 7);
    const weekAgoStr = weekAgo.toISOString().slice(0, 10);
    const { data: sales } = await supabase.from('sales').select('total_amount, cashier_name, date_str').eq('business_id', business_id).gte('date_str', weekAgoStr);

    const totalRevenue = (sales || []).reduce((s, r) => s + Number(r.total_amount || 0), 0);
    const totalSales = (sales || []).length;
    const formatted = totalRevenue.toLocaleString('en', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

    const rows = (sales || []).map(s => `<tr><td>${s.date_str}</td><td>${s.cashier_name}</td><td>K${Number(s.total_amount).toFixed(2)}</td></tr>`).join('');

    const html = `
      <div style="font-family:sans-serif;max-width:600px;margin:0 auto">
        <h2 style="color:#007AFF">📊 Weekly Sales Report — ${business?.name || 'Your Business'}</h2>
        <p>Here's your sales summary for the past 7 days:</p>
        <div style="background:#f2f2f7;border-radius:12px;padding:20px;margin:16px 0">
          <div style="font-size:28px;font-weight:800;color:#007AFF">K${formatted}</div>
          <div style="color:#636366;margin-top:4px">${totalSales} sales this week</div>
        </div>
        <table style="width:100%;border-collapse:collapse;font-size:13px">
          <thead><tr style="background:#007AFF;color:#fff"><th style="padding:8px">Date</th><th style="padding:8px">Cashier</th><th style="padding:8px">Amount</th></tr></thead>
          <tbody>${rows || '<tr><td colspan="3" style="text-align:center;padding:16px;color:#999">No sales this week</td></tr>'}</tbody>
        </table>
        <p style="color:#999;font-size:12px;margin-top:24px">Marble POS — automated weekly report</p>
      </div>`;

    // Send via Resend
    const { Resend } = require('resend');
    const resend = new Resend(process.env.RESEND_API_KEY);
    await resend.emails.send({
      from: process.env.RESEND_FROM_EMAIL || 'reports@marblepos.app',
      to: ownerEmail,
      subject: `Weekly Sales Report — ${business?.name || 'Your Business'}`,
      html
    });

    res.json({ ok: true, sent_to: ownerEmail, total_revenue: totalRevenue, total_sales: totalSales });
  } catch (err) {
    console.error('Weekly report error:', err.message);
    res.status(500).json({ error: err.message });
  }
});
app.listen(process.env.PORT || 3000, () =>
  console.log(`Marble POS backend running on port ${process.env.PORT || 3000}`)
);

// =============================================================================
// CRON — Send weekly reports every Monday at 8:00 AM
// Requires: npm install node-cron
// =============================================================================
try {
  const cron = require('node-cron');
  cron.schedule('0 8 * * 1', async () => {
    console.log('[cron] Sending weekly reports...');
    try {
      // Get all distinct business_ids
      const { data: businesses } = await supabase.from('businesses').select('id');
      for (const biz of (businesses || [])) {
        await fetch(`http://localhost:${process.env.PORT || 3000}/send-weekly-report`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'x-cron-secret': process.env.CRON_SECRET },
          body: JSON.stringify({ business_id: biz.id })
        }).catch(e => console.error('[cron] report failed for', biz.id, e.message));
      }
    } catch (e) { console.error('[cron] error:', e.message); }
  });
  console.log('[cron] Weekly report scheduler active (Mon 08:00)');
} catch (e) {
  console.warn('[cron] node-cron not installed — run: npm install node-cron');
}
