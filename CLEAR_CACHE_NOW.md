# CRITICAL: Clear Browser Cache NOW

## The Problem
Your browser has cached the OLD `supabase.js` file with the WRONG Supabase credentials. That's why you're still seeing errors with `dzpdcfmlavcnhwmjjmbf.supabase.co` even though the code has been fixed.

## The Solution - Choose ONE method:

### Method 1: Hard Refresh (Quickest)
1. Open your app in the browser
2. Press `Ctrl + Shift + R` (Windows) or `Cmd + Shift + R` (Mac)
3. This forces the browser to reload everything from the server

### Method 2: Clear Cache via DevTools (Most Reliable)
1. Open your app in the browser
2. Press `F12` to open DevTools
3. Right-click the refresh button (next to the address bar)
4. Select "Empty Cache and Hard Reload"

### Method 3: Clear All Site Data (Nuclear Option)
1. Open your app in the browser
2. Press `F12` to open DevTools
3. Go to "Application" tab (Chrome) or "Storage" tab (Firefox)
4. Click "Clear site data" or "Clear storage"
5. Refresh the page

### Method 4: Use Incognito/Private Window
1. Open a new Incognito/Private window
2. Navigate to your app URL
3. This bypasses all cache

## What Changed
- Added `?v=4` to all `supabase.js` script tags (cache-busting)
- Bumped service worker cache from v3 to v4
- All files now use correct Supabase URL: `https://ydogahzvieaunitxaoim.supabase.co`

## After Clearing Cache
You should see a 400 error instead of 401. This is GOOD - it means:
- ✅ Correct Supabase project is being used
- ✅ Credentials are correct
- ⚠️ User doesn't exist yet (you need to create it in Supabase)

## Next Step: Create User in Supabase
1. Go to: https://app.supabase.com/project/ydogahzvieaunitxaoim/auth/users
2. Click "Add user"
3. Email: `admin@origination-stores.com`
4. Password: `Admin123!`
5. **CHECK "Auto Confirm User"**
6. Click "Create user"

Then try logging in again!
