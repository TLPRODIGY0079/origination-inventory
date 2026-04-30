# Add Cashier Account

## Quick Method (Recommended)

### Step 1: Create User in Supabase Auth
1. Go to: https://app.supabase.com/project/ydogahzvieaunitxaoim/auth/users
2. Click "Add user" (green button)
3. Fill in:
   - **Email**: `cashier@origination-stores.com` (or any email)
   - **Password**: `Cashier123!` (or your choice)
   - **✅ CHECK "Auto Confirm User"** (important!)
4. Click "Create user"
5. **Copy the User ID** that appears (you'll need it in Step 2)

### Step 2: Create Profile in Database
1. Go to: https://app.supabase.com/project/ydogahzvieaunitxaoim/sql/new
2. Copy and paste this SQL (replace `YOUR_CASHIER_USER_ID` with the ID from Step 1):

```sql
-- Get your admin's business_id first
SELECT id, business_id FROM profiles WHERE role = 'admin';

-- Then create the cashier profile (replace BOTH IDs below)
INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
VALUES (
  'YOUR_CASHIER_USER_ID',  -- Replace with the user ID from Step 1
  'Cashier User',
  'cashier',
  'YOUR_ADMIN_BUSINESS_ID',  -- Replace with your admin's business_id from the query above
  'free',
  true
);
```

3. Click "Run"

### Step 3: Test Login
1. Open your app in incognito/private mode
2. Login with:
   - Email: `cashier@origination-stores.com`
   - Password: `Cashier123!`
3. You should see the POS system with limited access

## What Cashiers Can Do

✅ **Allowed:**
- View products
- Make sales (POS)
- View sales history
- View dashboard stats

❌ **Not Allowed:**
- Add/edit/delete products
- Manage inventory
- View settings
- Manage users
- Delete sales

## Add Multiple Cashiers

Repeat the steps above for each cashier:
- `cashier1@origination-stores.com`
- `cashier2@origination-stores.com`
- etc.

**Important:** Always use the same `business_id` (your admin's business_id) for all users in your organization.

## Quick SQL Template

Here's a template you can customize:

```sql
-- Step 1: Get your business_id
SELECT business_id FROM profiles WHERE role = 'admin' LIMIT 1;

-- Step 2: Create cashier (replace the values)
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

## Other Roles

You can create other roles too:

### Manager
```sql
INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
VALUES (
  'USER_ID',
  'Manager Name',
  'manager',  -- Can manage products and inventory
  'BUSINESS_ID',
  'free',
  true
);
```

### Storekeeper
```sql
INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
VALUES (
  'USER_ID',
  'Storekeeper Name',
  'storekeeper',  -- Can manage inventory and stock
  'BUSINESS_ID',
  'free',
  true
);
```

## Role Permissions Summary

| Action | Admin | Manager | Cashier | Storekeeper |
|--------|-------|---------|---------|-------------|
| Make Sales | ✅ | ✅ | ✅ | ❌ |
| View Sales | ✅ | ✅ | ✅ | ✅ |
| Add Products | ✅ | ✅ | ❌ | ❌ |
| Edit Products | ✅ | ✅ | ❌ | ❌ |
| Delete Products | ✅ | ❌ | ❌ | ❌ |
| Manage Stock | ✅ | ✅ | ❌ | ✅ |
| Delete Sales | ✅ | ❌ | ❌ | ❌ |
| View Analytics | ✅ | ✅ | ✅ | ✅ |
| Manage Users | ✅ | ❌ | ❌ | ❌ |
| Settings | ✅ | ❌ | ❌ | ❌ |

## Troubleshooting

### "User already exists"
The email is already registered. Use a different email or delete the existing user first.

### "Cannot insert duplicate key"
The user ID already has a profile. Check if the profile exists:
```sql
SELECT * FROM profiles WHERE id = 'USER_ID';
```

### Cashier can't log in
1. Make sure "Auto Confirm User" was checked
2. Check the user exists in Auth: https://app.supabase.com/project/ydogahzvieaunitxaoim/auth/users
3. Check the profile exists:
```sql
SELECT * FROM profiles WHERE id = 'USER_ID';
```

### Cashier sees "Permission denied"
Make sure the `business_id` matches your admin's business_id:
```sql
SELECT id, role, business_id FROM profiles;
```

All users in the same organization must have the same `business_id`.

## Security Notes

- Each user needs their own email address
- Use strong passwords (min 6 characters)
- Cashiers can only see data from their own business
- Row Level Security (RLS) enforces permissions automatically
- Admins can view all users in their business

## Next Steps

After creating cashier accounts:
1. Test login with each account
2. Verify permissions work correctly
3. Train cashiers on the POS system
4. Monitor sales activity in the dashboard
