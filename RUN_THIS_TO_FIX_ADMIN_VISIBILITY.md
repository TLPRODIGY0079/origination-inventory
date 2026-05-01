# 🚀 Quick Fix: Admin Can't See Cashier Sales

## The Problem

Admin is not seeing sales made by cashiers on the dashboard or sales history.

## The Solution

Run one SQL file to fix it!

---

## Step 1: Open Supabase SQL Editor

1. Go to your Supabase project: https://supabase.com/dashboard
2. Click on your project: **ydogahzvieaunitxaoim**
3. Click **SQL Editor** in the left sidebar
4. Click **New query**

---

## Step 2: Copy and Run This SQL

Open the file **`FIX_BUSINESS_ID_NOW.sql`** and copy ALL the content.

Paste it into the SQL Editor and click **Run**.

**What it does**:
- Checks current business_id values
- Sets the same business_id for all users (admin, cashiers, managers)
- Updates all sales with the correct business_id
- Verifies the fix worked

---

## Step 3: Clear Browser Cache

After running the SQL:

1. Press **Ctrl + Shift + Delete**
2. Select **Cached images and files**
3. Click **Clear data**

Or just press **Ctrl + F5** for a hard refresh.

---

## Step 4: Test It

1. **Login as Cashier** and make a test sale
2. **Login as Admin** (different browser or incognito)
3. **Go to Dashboard** - you should see the cashier's sale in "Today's Sales"
4. **Go to Sales History** - you should see the cashier's sale in the table

---

## Why This Fixes It

The system uses `business_id` to determine which sales each user can see:
- All users with the **same business_id** see the **same sales**
- If business_id is NULL or different, users see different data

The SQL fix ensures everyone has the same business_id.

---

## That's It!

After running the SQL and clearing cache, admin will see ALL sales from:
- ✅ Cashiers
- ✅ Managers
- ✅ Other admins
- ✅ Everyone in the business

**Run the SQL now!** 🎉
