-- =============================================================================
-- Fix All Current Issues - Run This Now
-- =============================================================================

-- ISSUE 1: Fix the plan check constraint (must be lowercase)
-- =============================================================================
-- The error: "Pro" should be "pro"

-- Create Victor's admin profile (CORRECTED)
INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
VALUES (
  '3a7f7bbb-ff9b-4aec-a58f-e759a6f5c433',
  'Victor Mulenga',
  'admin',
  '3a7f7bbb-ff9b-4aec-a58f-e759a6f5c433',
  'pro',  -- ✅ LOWERCASE (was 'Pro')
  true
)
ON CONFLICT (id) DO UPDATE SET
  full_name = 'Victor Mulenga',
  role = 'admin',
  business_id = '3a7f7bbb-ff9b-4aec-a58f-e759a6f5c433',
  plan = 'pro',
  onboarding_completed = true;

-- ISSUE 2: Add co-admin (kaelachanda2004@gmail.com)
-- =============================================================================

-- First, find the user ID for this email
SELECT id, email FROM auth.users WHERE email = 'kaelachanda2004@gmail.com';

-- Create/update profile for co-admin (replace USER-ID if needed)
INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
SELECT 
  au.id,
  COALESCE(au.raw_user_meta_data->>'full_name', 'Co-Admin') as full_name,
  'admin' as role,
  '3a7f7bbb-ff9b-4aec-a58f-e759a6f5c433' as business_id,
  'pro' as plan,
  true as onboarding_completed
FROM auth.users au
WHERE au.email = 'kaelachanda2004@gmail.com'
ON CONFLICT (id) DO UPDATE SET
  role = 'admin',
  business_id = '3a7f7bbb-ff9b-4aec-a58f-e759a6f5c433',
  plan = 'pro',
  onboarding_completed = true;

-- ISSUE 3: Remove 'imei' column references (doesn't exist in schema)
-- =============================================================================
-- The serialized_items table only has 'serial', not 'imei'
-- This is a frontend code issue - will fix separately

-- ISSUE 4: Fix RLS policies for sale_items and stock_moves
-- =============================================================================

-- Enable RLS if not already enabled
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_moves ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "sale_items_select" ON sale_items;
DROP POLICY IF EXISTS "sale_items_insert" ON sale_items;
DROP POLICY IF EXISTS "sale_items_update" ON sale_items;
DROP POLICY IF EXISTS "sale_items_delete" ON sale_items;

DROP POLICY IF EXISTS "stock_moves_select" ON stock_moves;
DROP POLICY IF EXISTS "stock_moves_insert" ON stock_moves;
DROP POLICY IF EXISTS "stock_moves_update" ON stock_moves;
DROP POLICY IF EXISTS "stock_moves_delete" ON stock_moves;

-- Create helper function to get business_id from sale
CREATE OR REPLACE FUNCTION get_sale_business_id(sale_id_param TEXT)
RETURNS UUID AS $$
  SELECT business_id FROM sales WHERE id = sale_id_param LIMIT 1;
$$ LANGUAGE SQL STABLE;

-- Create helper function to get business_id from variant
CREATE OR REPLACE FUNCTION get_variant_business_id(variant_id_param TEXT)
RETURNS UUID AS $$
  SELECT business_id FROM variants WHERE id = variant_id_param LIMIT 1;
$$ LANGUAGE SQL STABLE;

-- Sale Items Policies
CREATE POLICY "sale_items_select" ON sale_items FOR SELECT
  TO authenticated
  USING (get_sale_business_id(sale_id) = get_my_business_id());

CREATE POLICY "sale_items_insert" ON sale_items FOR INSERT
  TO authenticated
  WITH CHECK (get_sale_business_id(sale_id) = get_my_business_id());

CREATE POLICY "sale_items_update" ON sale_items FOR UPDATE
  TO authenticated
  USING (get_sale_business_id(sale_id) = get_my_business_id())
  WITH CHECK (get_sale_business_id(sale_id) = get_my_business_id());

CREATE POLICY "sale_items_delete" ON sale_items FOR DELETE
  TO authenticated
  USING (get_sale_business_id(sale_id) = get_my_business_id() AND get_my_role() = 'admin');

-- Stock Moves Policies
CREATE POLICY "stock_moves_select" ON stock_moves FOR SELECT
  TO authenticated
  USING (get_variant_business_id(variant_id) = get_my_business_id());

CREATE POLICY "stock_moves_insert" ON stock_moves FOR INSERT
  TO authenticated
  WITH CHECK (get_variant_business_id(variant_id) = get_my_business_id());

CREATE POLICY "stock_moves_update" ON stock_moves FOR UPDATE
  TO authenticated
  USING (get_variant_business_id(variant_id) = get_my_business_id())
  WITH CHECK (get_variant_business_id(variant_id) = get_my_business_id());

CREATE POLICY "stock_moves_delete" ON stock_moves FOR DELETE
  TO authenticated
  USING (get_variant_business_id(variant_id) = get_my_business_id() AND get_my_role() = 'admin');

-- ISSUE 5: Ensure product deletion cascades to variants
-- =============================================================================
-- This should already be set up, but let's verify

-- Check current foreign key constraint
SELECT 
  tc.constraint_name, 
  tc.table_name, 
  kcu.column_name, 
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name,
  rc.delete_rule
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
JOIN information_schema.referential_constraints AS rc
  ON tc.constraint_name = rc.constraint_name
WHERE tc.table_name = 'variants' 
  AND tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_name = 'products';

-- If delete_rule is not 'CASCADE', fix it:
-- (The schema already has ON DELETE CASCADE, so this should be fine)

-- ISSUE 6: Set all users' onboarding_completed to true
-- =============================================================================

UPDATE profiles SET onboarding_completed = true WHERE onboarding_completed IS NULL OR onboarding_completed = false;

-- ISSUE 7: Verify all admins have same business_id
-- =============================================================================

SELECT id, full_name, role, business_id, plan, onboarding_completed
FROM profiles
WHERE role = 'admin'
ORDER BY created_at;

-- If any admin has different business_id, fix it:
UPDATE profiles
SET business_id = '3a7f7bbb-ff9b-4aec-a58f-e759a6f5c433'
WHERE role = 'admin' AND (business_id IS NULL OR business_id != '3a7f7bbb-ff9b-4aec-a58f-e759a6f5c433');

-- =============================================================================
-- VERIFICATION
-- =============================================================================

-- Check all admins
SELECT 
  p.id,
  p.full_name,
  p.role,
  p.business_id,
  p.plan,
  p.onboarding_completed,
  au.email
FROM profiles p
JOIN auth.users au ON au.id = p.id
WHERE p.role = 'admin'
ORDER BY p.created_at;

-- Expected result: Both Victor and kaelachanda2004@gmail.com should be admins with same business_id

-- Check RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename IN ('sale_items', 'stock_moves')
ORDER BY tablename, policyname;

-- =============================================================================
-- DONE!
-- =============================================================================
-- After running this:
-- 1. Clear browser cache (Ctrl + Shift + Delete)
-- 2. Reconnect to internet
-- 3. Reload the page
-- 4. Login as admin
-- =============================================================================
