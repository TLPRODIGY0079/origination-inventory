-- =============================================================================
-- Check Business ID Configuration
-- Run this in Supabase SQL Editor to verify all users are in the same business
-- =============================================================================

-- 1. Check all user profiles and their business_id
SELECT 
  id,
  full_name,
  role,
  business_id,
  created_at
FROM profiles
ORDER BY role, full_name;

-- Expected result: All users should have the SAME business_id
-- If business_id is NULL or different, that's the problem!

-- =============================================================================
-- 2. Check sales and their business_id
SELECT 
  id,
  receipt_no,
  cashier_name,
  total,
  business_id,
  date_str
FROM sales
ORDER BY date DESC
LIMIT 20;

-- Expected result: All sales should have the SAME business_id as the users

-- =============================================================================
-- 3. If business_id is NULL or inconsistent, run this fix:
-- =============================================================================

-- OPTION A: Set a default business_id for all users (if you have only one business)
-- Uncomment and run if needed:

-- UPDATE profiles 
-- SET business_id = (SELECT id FROM profiles WHERE role = 'admin' LIMIT 1)
-- WHERE business_id IS NULL;

-- OPTION B: Set a specific UUID for all users
-- Replace 'YOUR-BUSINESS-UUID-HERE' with your actual business UUID
-- Uncomment and run if needed:

-- UPDATE profiles 
-- SET business_id = 'YOUR-BUSINESS-UUID-HERE'
-- WHERE business_id IS NULL OR business_id != 'YOUR-BUSINESS-UUID-HERE';

-- UPDATE sales 
-- SET business_id = 'YOUR-BUSINESS-UUID-HERE'
-- WHERE business_id IS NULL OR business_id != 'YOUR-BUSINESS-UUID-HERE';

-- =============================================================================
-- 4. Verify the fix worked
-- =============================================================================

-- Check that all users now have the same business_id:
SELECT 
  role,
  COUNT(*) as user_count,
  business_id
FROM profiles
GROUP BY role, business_id
ORDER BY role;

-- Expected result: All roles should show the SAME business_id

-- =============================================================================
-- NOTES:
-- - If business_id is NULL, users won't see any data due to RLS policies
-- - If business_id is different, users will see different data sets
-- - Admin with business_id 'A' cannot see sales from cashier with business_id 'B'
-- =============================================================================
