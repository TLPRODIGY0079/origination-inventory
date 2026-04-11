require('dotenv').config();
const express = require('express');
const cors = require('cors');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const { createClient } = require('@supabase/supabase-js');

const app = express();
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY  // service-role key — can bypass RLS
);

// ── CORS ──────────────────────────────────────────────────────────────────────
app.use(cors({ origin: process.env.FRONTEND_URL }));

// ── Raw body for Stripe webhook (must come BEFORE express.json()) ─────────────
app.post('/webhook', express.raw({ type: 'application/json' }), handleStripeWebhook);

// ── JSON body for all other routes ────────────────────────────────────────────
app.use(express.json());

// ─────────────────────────────────────────────────────────────────────────────
// POST /create-checkout-session
// Body: { userId, email, plan }
// Returns: { url }  — Stripe-hosted checkout page
// ─────────────────────────────────────────────────────────────────────────────
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
      metadata: { userId, plan },          // passed through to webhook
      line_items: [{
        price_data: {
          currency: 'zmw',                 // Zambian Kwacha — change to 'usd' if needed
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

// ─────────────────────────────────────────────────────────────────────────────
// POST /webhook  (Stripe calls this — raw body required)
// ─────────────────────────────────────────────────────────────────────────────
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
      const { error } = await supabase
        .from('profiles')
        .update({ plan })
        .eq('id', userId);

      if (error) console.error('Supabase update failed:', error.message);
      else console.log(`✓ Plan upgraded to "${plan}" for user ${userId}`);
    }
  }

  if (event.type === 'customer.subscription.deleted') {
    // Subscription cancelled — downgrade back to free
    const customerId = event.data.object.customer;
    // Look up userId via customer email if needed
    console.log('Subscription cancelled for Stripe customer:', customerId);
    // TODO: map customerId → userId and set plan = 'free'
  }

  res.sendStatus(200);
}

// ─────────────────────────────────────────────────────────────────────────────
// POST /mtn-initiate   (stub — replace with real MTN MoMo API call)
// Body: { userId, phone, amount, plan }
// ─────────────────────────────────────────────────────────────────────────────
app.post('/mtn-initiate', async (req, res) => {
  const { userId, phone, amount, plan } = req.body;
  if (!userId || !phone) return res.status(400).json({ error: 'userId and phone required' });

  // ── TODO: call MTN MoMo Collections API here ──────────────────────────────
  // const mtn = require('./mtn');
  // const result = await mtn.requestToPay({ phone, amount, externalId: userId });
  // Store result.referenceId so you can poll/verify later
  // ─────────────────────────────────────────────────────────────────────────

  // Simulated success for now
  console.log(`MTN MoMo payment initiated: ${phone} → K${amount} (plan: ${plan})`);
  res.json({ status: 'pending', message: 'Check your phone for the MoMo prompt' });
});

// ─────────────────────────────────────────────────────────────────────────────
// POST /mtn-confirm   (called after user confirms on phone — or via MTN callback)
// Body: { userId, referenceId, plan }
// ─────────────────────────────────────────────────────────────────────────────
app.post('/mtn-confirm', async (req, res) => {
  const { userId, plan } = req.body;

  // ── TODO: verify payment status with MTN API before trusting ─────────────
  // const mtn = require('./mtn');
  // const status = await mtn.getPaymentStatus(referenceId);
  // if (status !== 'SUCCESSFUL') return res.status(402).json({ error: 'Payment not confirmed' });
  // ─────────────────────────────────────────────────────────────────────────

  const { error } = await supabase.from('profiles').update({ plan }).eq('id', userId);
  if (error) return res.status(500).json({ error: error.message });

  console.log(`✓ MTN MoMo confirmed — plan "${plan}" for user ${userId}`);
  res.json({ success: true });
});

// ─────────────────────────────────────────────────────────────────────────────
app.listen(process.env.PORT || 3000, () =>
  console.log(`Marble POS backend running on port ${process.env.PORT || 3000}`)
);
