# 👤 Add Cashier - 3 Simple Steps

## Step 1: Create User in Supabase (2 minutes)

1. **Open Supabase Auth:**
   ```
   https://app.supabase.com/project/ydogahzvieaunitxaoim/auth/users
   ```

2. **Click "Add user"** (green button in top right)

3. **Fill in the form:**
   ```
   Email: cashier@origination-stores.com
   Password: Cashier123!
   ✅ Auto Confirm User (CHECK THIS BOX!)
   ```

4. **Click "Create user"**

5. **Copy the User ID** (looks like: `abc12345-1234-5678-90ab-cdef12345678`)

## Step 2: Get Your Business ID (30 seconds)

1. **Open SQL Editor:**
   ```
   https://app.supabase.com/project/ydogahzvieaunitxaoim/sql/new
   ```

2. **Run this query:**
   ```sql
   SELECT business_id FROM profiles WHERE role = 'admin' LIMIT 1;
   ```

3. **Copy the business_id** from the result

## Step 3: Create Profile (1 minute)

1. **In the same SQL Editor, run this:**
   ```sql
   INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
   VALUES (
     'PASTE_USER_ID_HERE',
     'Cashier Name',
     'cashier',
     'PASTE_BUSINESS_ID_HERE',
     'free',
     true
   );
   ```

2. **Replace:**
   - `PASTE_USER_ID_HERE` → User ID from Step 1
   - `Cashier Name` → Actual cashier name
   - `PASTE_BUSINESS_ID_HERE` → Business ID from Step 2

3. **Click "Run"**

## Done! 🎉

The cashier can now log in:
- **URL:** Your app URL
- **Email:** `cashier@origination-stores.com`
- **Password:** `Cashier123!`

## What Cashiers See

✅ Dashboard (view only)
✅ POS (can make sales)
✅ Products (view only)
✅ Sales History (view only)
❌ Settings (no access)
❌ Add/Edit Products (no access)

## Add More Cashiers

Repeat the steps with different emails:
- `cashier1@origination-stores.com`
- `cashier2@origination-stores.com`
- `cashier3@origination-stores.com`

**Important:** Always use the SAME business_id for all users!

## Quick Reference

| File | Purpose |
|------|---------|
| `ADD_CASHIER_ACCOUNT.md` | Detailed guide with troubleshooting |
| `create_cashier.sql` | SQL template with examples |
| `CASHIER_QUICK_START.md` | This file - quick 3-step guide |

## Need Help?

See `ADD_CASHIER_ACCOUNT.md` for:
- Role permissions table
- Troubleshooting common issues
- How to add managers and storekeepers
- Security notes
