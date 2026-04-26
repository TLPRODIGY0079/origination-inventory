# Vercel Deployment - Quick Start Guide

## 🚀 Deploy to Vercel in 3 Minutes

---

## Step 1: Push to GitHub (1 minute)

```bash
# In your project folder
git add .
git commit -m "Complete Origination-Inventory rebrand"
git remote add origin https://github.com/YOUR_USERNAME/origination-inventory.git
git branch -M main
git push -u origin main
```

---

## Step 2: Deploy to Vercel (1 minute)

### Via Vercel Dashboard (Easiest)

1. Go to: https://vercel.com
2. Click **"Add New"** → **"Project"**
3. Click **"Import"** next to your repository
4. Configure:
   - **Framework Preset**: Other
   - **Root Directory**: `./`
   - **Build Command**: (leave empty)
   - **Output Directory**: `.`
5. Click **"Deploy"**

### Via Vercel CLI

```bash
npm install -g vercel
vercel login
vercel
vercel --prod
```

---

## Step 3: Configure Supabase (1 minute)

1. Go to: https://app.supabase.com/project/ydogahzvieaunitxaoim/settings/api
2. Scroll to **CORS Settings**
3. Add your Vercel URL:
   ```
   https://origination-inventory.vercel.app
   ```
4. Click **"Save"**

---

## 🎉 Done!

Your site is live at: `https://origination-inventory.vercel.app`

---

## Create Your First User

### Option 1: Via Supabase Dashboard

1. Go to: https://app.supabase.com/project/ydogahzvieaunitxaoim/auth/users
2. Click **"Add user"**
3. Enter:
   - Email: `admin@origination-stores.com`
   - Password: (create a strong password)
   - ✓ Auto Confirm User
4. Click **"Create user"**

### Option 2: Via Signup Page

1. Visit: `https://origination-inventory.vercel.app/signup.html`
2. Fill in the form
3. Check email for confirmation
4. Click confirmation link

---

## Test Login

1. Visit: `https://origination-inventory.vercel.app`
2. Enter your email and password
3. Click "Sign In"
4. You're in! 🎉

---

## How It Works

### Authentication Flow

```
User visits Vercel site
    ↓
Not logged in? → Show login page
    ↓
User enters credentials
    ↓
Supabase authenticates
    ↓
Success! → Access POS system
```

### What Happens Where

- **Vercel**: Hosts your HTML/CSS/JS files
- **Supabase**: Handles authentication and database
- **Browser**: Stores session, makes API calls

**No server-side code needed!** Everything runs in the browser.

---

## Automatic Deployments

Every push to GitHub automatically deploys:

```bash
# Make changes
git add .
git commit -m "Update feature"
git push origin main

# Vercel deploys automatically!
```

---

## Troubleshooting

### Problem: Login doesn't work

**Check:**
1. Supabase CORS includes Vercel URL
2. User exists in Supabase
3. User is confirmed (Auto Confirm checked)
4. Browser console for errors

### Problem: "Failed to fetch"

**Solution:**
- Add Vercel URL to Supabase CORS settings
- Check Supabase project is not paused

### Problem: Assets not loading

**Solution:**
- Check paths are relative: `assets/logos/...`
- Not absolute: `/assets/logos/...`

---

## Quick Links

- **Your Site**: https://origination-inventory.vercel.app
- **Vercel Dashboard**: https://vercel.com/dashboard
- **Supabase Users**: https://app.supabase.com/project/ydogahzvieaunitxaoim/auth/users
- **Supabase CORS**: https://app.supabase.com/project/ydogahzvieaunitxaoim/settings/api

---

## Next Steps

1. ✅ Create users in Supabase
2. ✅ Test login on your Vercel site
3. ✅ Share URL with your team
4. ✅ Start using the POS system!

---

**Need more details?** Read `VERCEL_SUPABASE_SETUP.md` for complete guide.

**Ready to deploy? Start with Step 1!** 🚀
