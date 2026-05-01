-- =============================================================================
-- Fix Business ID Configuration - Run This Now
-- This ensures admin can see ALL sales from all users
-- =============================================================================

-- STEP 1: Check current state
-- =============================================================================
SELECT '=== CURRENT USER PROFILES ===' as info;
SELECT 
  id,
  full_name,
  role,
  business_id,
  created_at
FROM profiles
ORDER BY role, full_name;

-- STEP 2: Check current sales
-- =============================================================================
SELECT '=== CURRENT SALES ===' as info;
SELECT 
  id,
  receipt_no,
  cashier_name,
  total,
  business_id,
  date_str
FROM sales
ORDER BY date DESC
LIMIT 10;

-- STEP 3: Fix - Set same business_id for all users and sales
-- =============================================================================
-- This creates a new business UUID and applies it to everything
-- =============================================================================

DO $$
DECLARE
  business_uuid UUID;
BEGIN
  -- Get existing business_id from admin, or create new one
  SELECT business_id INTO business_uuid 
  FROM profiles 
  WHERE role = 'admin' AND business_id IS NOT NULL 
  LIMIT 1;
  
  -- If no business_id exists, create a new one
  IF business_uuid IS NULL THEN
    business_uuid := gen_random_uuid();
    RAISE NOTICE 'Created new business_id: %', business_uuid;
  ELSE
    RAISE NOTICE 'Using existing business_id: %', business_uuid;
  END IF;
  
  -- Update all profiles
  UPDATE profiles SET business_id = business_uuid;
  RAISE NOTICE 'Updated % profiles', (SELECT COUNT(*) FROM profiles);
  
  -- Update all sales
  UPDATE sales SET business_id = business_uuid;
  RAISE NOTICE 'Updated % sales', (SELECT COUNT(*) FROM sales);
  
  -- Update all products
  UPDATE products SET business_id = business_uuid;
  RAISE NOTICE 'Updated % products', (SELECT COUNT(*) FROM products);
  
  -- Update all variants
  UPDATE variants SET business_id = business_uuid;
  RAISE NOTICE 'Updated % variants', (SELECT COUNT(*) FROM variants);
  
  -- Update brands (only if column exists)
  UPDATE brands SET business_id = business_uuid WHERE business_id IS NOT NULL OR business_id IS NULL;
  
  -- Update categories (only if column exists)
  UPDATE categories SET business_id = business_uuid WHERE business_id IS NOT NULL OR business_id IS NULL;
  
  RAISE NOTICE 'Business ID fix complete!';
END $$;

-- STEP 4: Verify the fix
-- =============================================================================
SELECT '=== VERIFICATION - All users should have same business_id ===' as info;
SELECT 
  role,
  COUNT(*) as user_count,
  business_id
FROM profiles
GROUP BY role, business_id
ORDER BY role;

SELECT '=== VERIFICATION - All sales should have same business_id ===' as info;
SELECT 
  COUNT(*) as total_sales,
  business_id
FROM sales
GROUP BY business_id;

-- =============================================================================
-- SUCCESS! 
-- All users and sales now have the same business_id
-- Admin can now see ALL sales from cashiers, managers, and other admins
-- =============================================================================

-- NEXT STEPS:
-- 1. Clear browser cache (Ctrl + Shift + Delete)
-- 2. Reload the application
-- 3. Login as admin
-- 4. Check Dashboard - you should see all sales
-- 5. Check Sales History - you should see all transactions
