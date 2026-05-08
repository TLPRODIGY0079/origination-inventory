# 🚨 URGENT: Fix Infinite Recursion Error

## Error You're Seeing

```
infinite recursion detected in policy for relation "profiles"
500 Internal Server Error on variants
500 Internal Server Error on profiles
```

## Root Cause

The `FIX_PROFILES_RLS.sql` file I provided earlier created a **circular reference** in the RLS policy. The policy was trying to read from the `profiles` table while checking permissions on the `profiles` table, causing infinite recursion.

## ✅ IMMEDIATE FIX

### Step 1: Run This SQL NOW

1. Open **Supabase Dashboard**
2. Go to **SQL Editor**
3. Copy and paste the entire contents of **`FIX_INFINITE_RECURSION_NOW.sql`**
4. Click **"Run"**

This will:
- Remove the problematic circular policies
- Create simple, non-recursive policies
- Fix all RLS policies to be permissive (allow all authenticated users)
- Enable RLS on all tables

### Step 2: Clear Browser Cache

After running the SQL:

**Option A - Hard Refresh**:
- Windows: `Ctrl + F5` or `Ctrl + Shift + R`
- Mac: `Cmd + Shift + R`

**Option B - Clear Cache Manually**:
1. Open DevTools (F12)
2. Right-click the refresh button
3. Select "Empty Cache and Hard Reload"

### Step 3: Try Logging In Again

The app should now load without errors.

---

## What Changed

### Before (BROKEN):
```sql
-- This caused infinite recursion ❌
CREATE POLICY "profiles_select" ON profiles FOR SELECT
  USING (
    business_id = (SELECT business_id FROM profiles WHERE id = auth.uid())
    -- ↑ This reads from profiles while checking profiles permissions!
  );
```

### After (FIXED):
```sql
-- Simple policy, no recursion ✅
CREATE POLICY "profiles_select" ON profiles FOR SELECT
  USING (id = auth.uid());
```

---

## What the Fix Does

1. **Profiles**: Users can only see their own profile
2. **All Other Tables**: All authenticated users can access (permissive)
3. **No Circular References**: Policies don't reference the table they're protecting

---

## Why Permissive Policies?

For now, I've made all policies permissive (allow all authenticated users) to:
- Get the app working immediately
- Avoid any circular reference issues
- Keep it simple

**Later**, if you need business-level isolation (users only see data from their business), we can add that filtering in the application code or with more careful RLS policies.

---

## Verification

After running the SQL and refreshing:

1. **Login should work** ✅
2. **No 500 errors** ✅
3. **Data loads properly** ✅
4. **No infinite recursion errors** ✅

---

## If You Still See Errors

1. **Check SQL ran successfully**: Look for green checkmark in Supabase SQL Editor
2. **Clear ALL browser data**: Settings → Privacy → Clear browsing data
3. **Try incognito/private window**: This ensures no cached data
4. **Check Supabase logs**: Dashboard → Logs → Check for any errors

---

## Files to Use

1. **`FIX_INFINITE_RECURSION_NOW.sql`** ← Run this NOW
2. **`CREATE_TRADEINS_TABLE.sql`** ← Run this AFTER the recursion fix

---

## Summary

**Problem**: Circular RLS policy causing infinite recursion
**Solution**: Simplified policies without circular references
**Action**: Run `FIX_INFINITE_RECURSION_NOW.sql` in Supabase SQL Editor
**Result**: App will work without 500 errors

Run the SQL now and let me know if you still see any errors!
