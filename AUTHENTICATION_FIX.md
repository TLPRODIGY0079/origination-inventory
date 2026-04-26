# Authentication Issues - Fix Guide

## Problems Identified

1. ❌ **Multiple Supabase Projects** - Your code references TWO different Supabase projects
2. ❌ **Tracking Prevention** - Browser blocking storage access
3. ❌ **400 Error** - Authentication failing due to wrong credentials

---

## Problem 1: Multiple Supabase Projects

### Current State

Your code has TWO different Supabase URLs:

**In `supabase.js`:**
```javascript
const supabaseUrl = "https://ydogahzvieaunitxaoim.supabase.co";
```

**In `login.html` and `index.html`:**
```javascript
const _sc = window.supabase.createClient('https://dzpdcfmlavcnhwmjjmbf.supabase.co', ...);
```

### Which One to Use?

You need to decide which Supabase project to use. Check:

1. Go to https://app.supabase.com
2. See which project has your data
3. Use that project's credentials everywhere

### Fix: Use ONE Supabase Project Consistently

I'll update all files to use the SAME Supabase project.

**Which project do you want to use?**
- Project 1: `ydogahzvieaunitxaoim`
- Project 2: `dzpdcfmlavcnhwmjjmbf`

For now, I'll standardize on Project 2 (`dzpdcfmlavcnhwmjjmbf`) since it's used in more places.

---

## Problem 2: Tracking Prevention

### What's Happening

Safari/Firefox's tracking prevention is blocking:
- LocalStorage access
- SessionStorage access
- Cookie access from CDN domains

### Solutions

#### Solution A: Disable Tracking Prevention (For Testing)

**Safari:**
1. Safari → Preferences → Privacy
2. Uncheck "Prevent cross-site tracking"
3. Reload the page

**Firefox:**
1. Settings → Privacy & Security
2. Set "Enhanced Tracking Protection" to "Standard"
3. Reload the page

#### Solution B: Use First-Party Storage (Recommended)

Update Supabase client configuration to use first-party storage:

```javascript
const supabaseClient = window.supabase.createClient(
  'https://dzpdcfmlavcnhwmjjmbf.supabase.co',
  'sb_publishable_sDkdIiUQY0S2kNVoVwbUMg_f_zTObmk',
  {
    auth: {
      storage: window.localStorage,
      storageKey: 'origination-auth',
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: true
    }
  }
);
```

---

## Problem 3: 400 Error from Supabase

### Causes

1. **Wrong credentials** - Using wrong Supabase URL/key combination
2. **User doesn't exist** - No user created in Supabase
3. **Wrong password** - Incorrect password for existing user

### Fix Steps

1. **Verify Supabase Project:**
   - Go to https://app.supabase.com
   - Select project: `dzpdcfmlavcnhwmjjmbf`
   - Go to Settings → API
   - Copy the correct URL and anon key

2. **Create a Test User:**
   - Go to Authentication → Users
   - Click "Add user"
   - Email: `admin@origination-stores.com`
   - Password: `Admin123!`
   - ✓ Auto Confirm User
   - Click "Create user"

3. **Test Login:**
   - Visit your site
   - Use the email/password you just created
   - Should work now!

---

## Quick Fix Commands

I'll create fixed versions of your files. Run these after I create them:

```bash
# Backup current files
cp supabase.js supabase.js.backup
cp login.html login.html.backup
cp index.html index.html.backup

# After I create the fixed files, commit them
git add supabase.js login.html index.html signup.html
git commit -m "Fix: Standardize Supabase credentials and fix tracking prevention"
git push origin main
```

---

## Testing Checklist

After fixes are applied:

- [ ] Clear browser cache (Ctrl+Shift+Delete)
- [ ] Hard refresh (Ctrl+Shift+R)
- [ ] Open browser console (F12)
- [ ] Check for errors
- [ ] Try logging in
- [ ] Verify no "Multiple GoTrueClient" warning
- [ ] Verify no tracking prevention errors
- [ ] Verify no 400 errors

---

## Prevention

To avoid this in the future:

1. **Use environment variables** for Supabase credentials
2. **Import from one place** (supabase.js)
3. **Don't hardcode** credentials in multiple files
4. **Test in multiple browsers** (Chrome, Firefox, Safari)

---

Let me fix your files now...
