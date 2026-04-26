# 🔄 Cache Clear Instructions - IMPORTANT!

## Problem

Your browser is using a **cached version** of the old `supabase.js` file with wrong credentials. That's why you're still seeing the old project URL in the error.

## What I Fixed

✅ Updated ALL files to use correct project:
- `supabase.js` - Correct credentials
- `index.html` - Correct credentials
- `login.html` - Uses shared client
- `signup.html` - Uses shared client
- `payment.html` - Correct credentials
- `landing.html` - Correct credentials
- `sw.js` - Cache version bumped to v3

## Your Correct Credentials

```
Project: ydogahzvieaunitxaoim
URL: https://ydogahzvieaunitxaoim.supabase.co
Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## STEP 1: Clear Browser Cache (REQUIRED!)

### Chrome / Edge

1. Press `Ctrl+Shift+Delete` (Windows) or `Cmd+Shift+Delete` (Mac)
2. Select **"All time"**
3. Check these boxes:
   - ✓ Cookies and other site data
   - ✓ Cached images and files
4. Click **"Clear data"**
5. Close ALL browser tabs
6. Restart browser

### Firefox

1. Press `Ctrl+Shift+Delete`
2. Time range: **"Everything"**
3. Check:
   - ✓ Cookies
   - ✓ Cache
4. Click **"Clear Now"**
5. Close ALL tabs
6. Restart browser

### Safari

1. Safari → Preferences → Privacy
2. Click **"Manage Website Data"**
3. Click **"Remove All"**
4. Confirm
5. Close ALL tabs
6. Restart browser

---

## STEP 2: Hard Refresh

After clearing cache:

1. Open your site
2. Press `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)
3. This forces a fresh download of all files

---

## STEP 3: Verify Correct Project

1. Open browser console (F12)
2. Go to "Network" tab
3. Try to log in
4. Look for the POST request
5. **Should see:** `https://ydogahzvieaunitxaoim.supabase.co/auth/v1/token`
6. **Should NOT see:** `https://dzpdcfmlavcnhwmjjmbf.supabase.co`

---

## STEP 4: Create User in Correct Project

Go to: https://app.supabase.com/project/ydogahzvieaunitxaoim/auth/users

Click "Add user":
- Email: `admin@origination-stores.com`
- Password: `Admin123!`
- ✓ **Auto Confirm User**
- Click "Create user"

---

## STEP 5: Push Changes

```bash
git add .
git commit -m "Fix: Update all files to use correct Supabase project"
git push origin main
```

Wait for deployment to complete (Vercel/Netlify will auto-deploy).

---

## STEP 6: Test Login

1. Visit your deployed site (NOT localhost)
2. Clear cache again if needed
3. Hard refresh (Ctrl+Shift+R)
4. Try logging in with credentials from Step 4
5. Should work! ✅

---

## Alternative: Use Incognito/Private Mode

If you don't want to clear your main browser cache:

1. Open **Incognito/Private window**
   - Chrome: `Ctrl+Shift+N`
   - Firefox: `Ctrl+Shift+P`
   - Safari: `Cmd+Shift+N`
2. Visit your site
3. Try logging in
4. This uses a fresh cache

---

## Still Not Working?

### Check Service Worker

1. Open DevTools (F12)
2. Go to "Application" tab (Chrome) or "Storage" tab (Firefox)
3. Click "Service Workers"
4. Click "Unregister" next to your site
5. Refresh page
6. Try again

### Check Local Storage

1. In DevTools, go to "Application" → "Local Storage"
2. Find your site
3. Delete all entries
4. Refresh page
5. Try again

### Nuclear Option: Clear Everything

```javascript
// Paste this in browser console (F12)
localStorage.clear();
sessionStorage.clear();
caches.keys().then(keys => keys.forEach(key => caches.delete(key)));
location.reload(true);
```

---

## Verification Checklist

After clearing cache and redeploying:

- [ ] Browser cache cleared
- [ ] Hard refresh performed
- [ ] Console shows correct URL (`ydogahzvieaunitxaoim`)
- [ ] User created in correct Supabase project
- [ ] Changes pushed to GitHub
- [ ] Deployment completed
- [ ] Login works!

---

## Why This Happened

1. You had two different Supabase projects in your code
2. Browser cached the old `supabase.js` file
3. Even after updating the file, browser kept using cached version
4. Service worker also cached old version
5. Solution: Clear cache + update service worker version

---

## Prevention

To avoid this in future:

1. **Use environment variables** instead of hardcoding
2. **Version your cache** (we did this: v2 → v3)
3. **Test in incognito** mode first
4. **Clear cache** when making credential changes

---

**After following these steps, your login should work!** 🚀

If you still see the old project URL in errors, the cache hasn't been cleared properly. Try incognito mode or a different browser.
