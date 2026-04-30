-- =============================================================================
-- Quick Script: Create Cashier Account
-- =============================================================================
-- 
-- INSTRUCTIONS:
-- 1. First, create the user in Supabase Auth Dashboard:
--    https://app.supabase.com/project/ydogahzvieaunitxaoim/auth/users
--    - Click "Add user"
--    - Email: cashier@origination-stores.com
--    - Password: Cashier123!
--    - ✅ CHECK "Auto Confirm User"
--    - Copy the User ID
--
-- 2. Then run this script, replacing the placeholders below
--
-- =============================================================================

-- Step 1: Find your admin's business_id
-- (Run this first to get the business_id)
SELECT 
  id as admin_user_id,
  full_name,
  business_id,
  role
FROM profiles 
WHERE role = 'admin' 
LIMIT 1;

-- Copy the business_id from the result above

-- =============================================================================

-- Step 2: Create the cashier profile
-- Replace these values:
--   - CASHIER_USER_ID: The user ID from Supabase Auth (Step 1 in instructions)
--   - ADMIN_BUSINESS_ID: The business_id from the query above
--   - Cashier Name: The cashier's actual name

INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
VALUES (
  'CASHIER_USER_ID',      -- ⚠️ REPLACE THIS with user ID from Auth
  'Cashier Name',         -- ⚠️ REPLACE THIS with actual name
  'cashier',
  'ADMIN_BUSINESS_ID',    -- ⚠️ REPLACE THIS with business_id from query above
  'free',
  true
)
ON CONFLICT (id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  role = EXCLUDED.role,
  business_id = EXCLUDED.business_id;

-- =============================================================================

-- Step 3: Verify the cashier was created
SELECT 
  id,
  full_name,
  role,
  business_id,
  created_at
FROM profiles
WHERE role = 'cashier'
ORDER BY created_at DESC;

-- =============================================================================
-- DONE! The cashier can now log in with their email and password.
-- =============================================================================

-- =============================================================================
-- EXAMPLE (with real values):
-- =============================================================================
-- 
-- If your admin's business_id is: 12345678-1234-1234-1234-123456789abc
-- And the new user ID from Auth is: 87654321-4321-4321-4321-cba987654321
-- 
-- Then your INSERT would look like:
--
-- INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
-- VALUES (
--   '87654321-4321-4321-4321-cba987654321',
--   'Sarah Johnson',
--   'cashier',
--   '12345678-1234-1234-1234-123456789abc',
--   'free',
--   true
-- );
--
-- =============================================================================
