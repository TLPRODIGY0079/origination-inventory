-- =============================================================================
-- Fix RLS Policies and Onboarding - Run After Creating Users
-- =============================================================================

-- STEP 1: Fix RLS policies for sale_items and stock_moves
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

-- STEP 2: Set all users' onboarding_completed to true
-- =============================================================================

UPDATE profiles 
SET onboarding_completed = true 
WHERE onboarding_completed IS NULL OR onboarding_completed = false;

-- STEP 3: Ensure all admins have same business_id
-- =============================================================================

-- Get the business_id from the first admin
DO $$
DECLARE
  admin_business_id UUID;
BEGIN
  SELECT business_id INTO admin_business_id 
  FROM profiles 
  WHERE role = 'admin' AND business_id IS NOT NULL 
  LIMIT 1;
  
  IF admin_business_id IS NOT NULL THEN
    UPDATE profiles
    SET business_id = admin_business_id
    WHERE role = 'admin' AND (business_id IS NULL OR business_id != admin_business_id);
    
    RAISE NOTICE 'Updated all admins to business_id: %', admin_business_id;
  ELSE
    RAISE NOTICE 'No admin with business_id found';
  END IF;
END $$;

-- STEP 4: Verification
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

-- Check RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename IN ('sale_items', 'stock_moves')
ORDER BY tablename, policyname;

-- =============================================================================
-- DONE!
-- =============================================================================
