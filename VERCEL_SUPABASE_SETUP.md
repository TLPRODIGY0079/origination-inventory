# Vercel + Supabase Authentication Setup Guide

## Overview

Your app uses **Supabase for authentication** and will be deployed on **Vercel**. Here's how it all works together.

---

## How Authentication Works

### Current Setup

Your app already has Supabase configured:
- **Supabase URL**: `https://ydogahzvieaunitxaoim.supabase.co`
- **Supabase Key**: Already in `supabase.js`
- **Authentication**: Handled by Supabase Auth

### The Flow

1. **User visits your Vercel site** → `https://your-app.vercel.app`
2. **App loads** → Checks if user is logged in (via Supabase)
3. **Not logged in?** → Shows login page
4. **User logs in** → Supabase authenticates
5. **Logged in!** → User can access the POS system

---

## Part 1: Set Up Supabase Authentication

### Step 1: Enable Email Authentication

1. Go to your Supabase dashboard: https://app.supabase.com
2. Select your project: `ydogahzvieaunitxaoim`
3. Go to **Authentication** → **Providers**
4. Make sure **Email** is enabled (it should be by default)

### Step 2: Create Your First User

You have **two options**:

#### Option A: Create User via Supabase Dashboard (Easiest)

1. In Supabase dashboard, go to **Authentication** → **Users**
2. Click **"Add user"** button
3. Fill in:
   - **Email**: `admin@origination-stores.com` (or your email)
   - **Password**: Create a strong password
   - **Auto Confirm User**: ✓ Check this box
4. Click **"Create user"**

#### Option B: Create User via Signup Page

1. Deploy your app first (see Part 2)
2. Visit: `https://your-app.vercel.app/signup.html`
3. Fill in the signup form
4. Check your email for confirmation link
5. Click the link to confirm

### Step 3: Configure Email Settings (Optional)

For production, you'll want custom email templates:

1. Go to **Authentication** → **Email Templates**
2. Customize:
   - Confirmation email
   - Password reset email
   - Magic link email
3. Update sender email in **Settings** → **Auth** → **SMTP Settings**

### Step 4: Update CORS Settings

1. Go to **Settings** → **API**
2. Scroll to **CORS Settings**
3. Add your Vercel URL (you'll get this after deployment):
   ```
   https://origination-inventory.vercel.app
   ```
4. Click **"Save"**

---

## Part 2: Deploy to Vercel

### Step 1: Push to GitHub (If Not Done)

```bash
git add .
git commit -m "Complete Origination-Inventory rebrand"
git remote add origin https://github.com/YOUR_USERNAME/origination-inventory.git
git branch -M main
git push -u origin main
```

### Step 2: Deploy to Vercel

#### Via Vercel Dashboard (Recommended)

1. Go to: https://vercel.com
2. Click **"Add New"** → **"Project"**
3. Click **"Import Git Repository"**
4. Select **"origination-inventory"**
5. Configure:
   - **Framework Preset**: Other
   - **Root Directory**: `./`
   - **Build Command**: Leave empty
   - **Output Directory**: `.`
6. Click **"Deploy"**

#### Via Vercel CLI

```bash
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Deploy
vercel

# Deploy to production
vercel --prod
```

### Step 3: Get Your Vercel URL

After deployment, you'll get a URL like:
```
https://origination-inventory.vercel.app
```

Copy this URL!

### Step 4: Update Supabase CORS

1. Go back to Supabase dashboard
2. **Settings** → **API** → **CORS Settings**
3. Add your Vercel URL:
   ```
   https://origination-inventory.vercel.app
   ```
4. Click **"Save"**

---

## Part 3: Test Authentication

### Step 1: Visit Your Deployed Site

Go to: `https://origination-inventory.vercel.app`

### Step 2: Try Logging In

**If you created a user in Supabase:**
1. Enter your email and password
2. Click "Sign In"
3. You should be logged in!

**If you haven't created a user yet:**
1. Click "Sign up free" link
2. Fill in the signup form
3. Check your email for confirmation
4. Click confirmation link
5. Go back and log in

### Step 3: Verify Authentication Works

After logging in, you should see:
- ✅ Dashboard loads
- ✅ Sidebar shows your name
- ✅ Can navigate between pages
- ✅ Can access POS features

---

## Part 4: Understanding the Authentication Code

### How Login Works

**In `login.html`:**
```javascript
// When user clicks "Sign In"
const { data, error } = await supabaseClient.auth.signInWithPassword({
  email: email,
  password: password
});

// If successful, redirect to main app
if (data.session) {
  window.location.href = 'index.html';
}
```

**In `index.html`:**
```javascript
// Check if user is logged in
const { data } = await supabaseClient.auth.getSession();
if (!data?.session) {
  // Not logged in, redirect to login page
  window.location.replace('login.html');
}
```

### Session Management

Supabase automatically:
- ✅ Stores session in browser
- ✅ Refreshes tokens automatically
- ✅ Handles logout
- ✅ Manages user state

---

## Part 5: Create Additional Users

### Method 1: Via Supabase Dashboard

1. **Authentication** → **Users**
2. Click **"Add user"**
3. Enter email and password
4. Check **"Auto Confirm User"**
5. Click **"Create user"**

### Method 2: Via Signup Page

1. Share signup link: `https://your-app.vercel.app/signup.html`
2. Users fill in the form
3. They receive confirmation email
4. They click link to confirm
5. They can now log in

### Method 3: Via Supabase API (Programmatic)

```javascript
// In your admin panel (future feature)
const { data, error } = await supabaseClient.auth.admin.createUser({
  email: 'newuser@example.com',
  password: 'secure-password',
  email_confirm: true
});
```

---

## Part 6: User Roles and Permissions

Your app has different user roles defined in the code:

### Default Users (from seed data)

```javascript
{id:'u-admin', username:'admin', password:'admin123', role:'admin'}
{id:'u-cashier', username:'cashier', password:'cash123', role:'cashier'}
{id:'u-manager', username:'manager', password:'mgr123', role:'manager'}
{id:'u-store', username:'store', password:'store123', role:'storekeeper'}
```

### Setting User Roles

**Option 1: Via Supabase Dashboard**
1. Go to **Authentication** → **Users**
2. Click on a user
3. Scroll to **User Metadata**
4. Add custom field:
   ```json
   {
     "role": "admin"
   }
   ```

**Option 2: Via Database**
1. Create a `profiles` table in Supabase
2. Link it to auth.users
3. Store role in profiles table

---

## Part 7: Security Best Practices

### 1. Environment Variables (Recommended)

Instead of hardcoding Supabase credentials, use environment variables:

**Create `.env.local`:**
```env
VITE_SUPABASE_URL=https://ydogahzvieaunitxaoim.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

**Update `supabase.js`:**
```javascript
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
```

**Add to Vercel:**
1. Go to Vercel dashboard
2. Select your project
3. **Settings** → **Environment Variables**
4. Add both variables

### 2. Row Level Security (RLS)

Your app already has RLS policies in `supabase/migrations/001_rls_policies.sql`

Make sure to run this migration:
```bash
# In Supabase SQL Editor
-- Copy and paste the contents of 001_rls_policies.sql
-- Click "Run"
```

### 3. Password Requirements

Configure in Supabase:
1. **Authentication** → **Policies**
2. Set minimum password length
3. Require special characters (optional)

---

## Part 8: Troubleshooting

### Problem: "Invalid login credentials"

**Solutions:**
- Check email and password are correct
- Verify user exists in Supabase dashboard
- Check if user is confirmed (email_confirmed_at is set)
- Try password reset

### Problem: "Failed to fetch"

**Solutions:**
- Check Supabase CORS settings include Vercel URL
- Verify Supabase URL and key are correct
- Check browser console for specific error
- Ensure Supabase project is not paused

### Problem: User gets logged out immediately

**Solutions:**
- Check session storage is enabled in browser
- Verify Supabase JWT secret is correct
- Check if session timeout is too short
- Clear browser cache and cookies

### Problem: Signup email not received

**Solutions:**
- Check spam folder
- Verify email provider settings in Supabase
- Check Supabase email logs
- Use "Auto Confirm User" for testing

---

## Part 9: Testing Checklist

### Authentication Tests

- [ ] Can visit login page
- [ ] Can log in with valid credentials
- [ ] Cannot log in with invalid credentials
- [ ] Error message shows for wrong password
- [ ] Can sign up new user
- [ ] Confirmation email received (if not auto-confirm)
- [ ] Can reset password
- [ ] Session persists on page refresh
- [ ] Can log out successfully
- [ ] Redirects to login when not authenticated

### Deployment Tests

- [ ] Site loads on Vercel
- [ ] Supabase connection works
- [ ] Login works on production
- [ ] No CORS errors in console
- [ ] Assets load correctly
- [ ] Mobile responsive works

---

## Part 10: Quick Reference

### Supabase Dashboard URLs

- **Project**: https://app.supabase.com/project/ydogahzvieaunitxaoim
- **Auth Users**: https://app.supabase.com/project/ydogahzvieaunitxaoim/auth/users
- **API Settings**: https://app.supabase.com/project/ydogahzvieaunitxaoim/settings/api

### Vercel Dashboard

- **Projects**: https://vercel.com/dashboard
- **Deployments**: https://vercel.com/[username]/origination-inventory

### Your App URLs

- **Production**: https://origination-inventory.vercel.app
- **Login**: https://origination-inventory.vercel.app/login.html
- **Signup**: https://origination-inventory.vercel.app/signup.html

---

## Summary

### What You Need to Do:

1. ✅ **Create users in Supabase** (via dashboard or signup page)
2. ✅ **Deploy to Vercel** (via dashboard or CLI)
3. ✅ **Update Supabase CORS** (add Vercel URL)
4. ✅ **Test login** (visit your Vercel URL and log in)

### That's It!

Your authentication is handled entirely by Supabase. When users visit your Vercel site:
- They see the login page
- They enter credentials
- Supabase authenticates them
- They access the POS system

**No additional configuration needed on Vercel for authentication!** 🎉

---

## Need Help?

- **Supabase Docs**: https://supabase.com/docs/guides/auth
- **Vercel Docs**: https://vercel.com/docs
- **Supabase Auth Guide**: https://supabase.com/docs/guides/auth/auth-email

---

**You're all set! Deploy to Vercel and start logging in!** 🚀
