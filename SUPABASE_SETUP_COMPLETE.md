# Complete Supabase Database Setup Guide

## Current Status
✅ Authentication is working - you successfully logged in!
❌ Database tables don't exist yet - that's why you see 404 errors

## What You Need To Do

### Step 1: Create Database Tables

1. Go to your Supabase SQL Editor:
   ```
   https://app.supabase.com/project/ydogahzvieaunitxaoim/sql/new
   ```

2. Copy and paste the ENTIRE content of this file:
   ```
   supabase/migrations/000_create_schema.sql
   ```

3. Click "Run" to execute the SQL

4. You should see: "Success. No rows returned"

### Step 2: Apply RLS Policies (Security)

1. In the same SQL Editor, copy and paste the ENTIRE content of:
   ```
   supabase/migrations/001_rls_policies.sql
   ```

2. Click "Run"

3. You should see: "Success. No rows returned"

### Step 3: Apply Rebrand Migration (Optional)

1. In the same SQL Editor, copy and paste the ENTIRE content of:
   ```
   supabase/migrations/002_rebrand_to_origination.sql
   ```

2. Click "Run"

3. You should see: "Success. No rows returned"

### Step 4: Create Your Admin User Profile

After running the migrations, you need to create a profile for your logged-in user:

1. Go to SQL Editor again
2. Run this query (replace the UUID with your actual user ID from the error message):

```sql
-- Get your user ID first
SELECT id, email FROM auth.users;

-- Then create your profile (replace YOUR_USER_ID with the actual UUID)
INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
VALUES (
  'YOUR_USER_ID',  -- Replace with your actual user ID
  'Admin User',
  'admin',
  gen_random_uuid(),  -- Creates a unique business ID
  'free',
  true
);
```

From your error, your user ID is: `974f1df3-b127-4cfd-924f-1a156af9a9a8`

So run:
```sql
INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
VALUES (
  '974f1df3-b127-4cfd-924f-1a156af9a9a8',
  'Admin User',
  'admin',
  gen_random_uuid(),
  'free',
  true
);
```

### Step 5: Test Your App

1. Refresh your browser (Ctrl+Shift+R)
2. You should now see the dashboard with:
   - Stats cards (Revenue, Sales, Products, etc.)
   - Empty state messages (since you have no data yet)
   - Working navigation

## What Each Migration Does

### 000_create_schema.sql
- Creates all database tables (profiles, products, variants, sales, etc.)
- Creates indexes for performance
- Inserts default categories and brands
- Sets up automatic timestamp updates

### 001_rls_policies.sql
- Enables Row Level Security (RLS)
- Creates security policies so users can only see their own business data
- Creates helper functions for role-based access control

### 002_rebrand_to_origination.sql
- Updates table comments with "Origination-stores" branding
- Adds app metadata table
- Optional - can skip if you want

## Troubleshooting

### Error: "relation already exists"
This means the table was already created. You can skip that migration or drop the table first.

### Error: "permission denied"
Make sure you're running the SQL as the postgres user (default in Supabase SQL Editor).

### Still seeing 404 errors after migrations
1. Clear your browser cache (Ctrl+Shift+R)
2. Check that all migrations ran successfully
3. Verify tables exist: Go to Table Editor in Supabase dashboard

### Can't see any data
This is normal! You just created an empty database. You need to:
1. Add products via the Products page
2. Create sales via the POS page
3. The dashboard will populate as you use the app

## Quick Verification

After running all migrations, verify tables exist:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

You should see:
- app_metadata
- audit_logs
- brands
- categories
- customers
- products
- profiles
- sale_items
- sales
- serialized_items
- stock_moves
- suppliers
- variants

## Next Steps

Once the database is set up:
1. ✅ Login works
2. ✅ Dashboard loads
3. ➡️ Add your first product
4. ➡️ Make your first sale
5. ➡️ Explore the analytics

## Need Help?

If you get stuck:
1. Check the browser console for specific error messages
2. Check the Supabase logs: https://app.supabase.com/project/ydogahzvieaunitxaoim/logs/explorer
3. Verify your user has a profile in the profiles table
