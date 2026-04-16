-- =============================================================================
-- Migration: 001_rls_policies.sql
-- Description: Apply RLS policies and helper functions for Marble POS
-- Apply this in the Supabase SQL editor (or via supabase db push)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Helper functions (SECURITY DEFINER so they run as the defining role,
--    bypassing RLS on the profiles table itself)
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_my_role()
RETURNS TEXT LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT role FROM profiles WHERE id = auth.uid()
$$;

CREATE OR REPLACE FUNCTION get_my_business_id()
RETURNS UUID LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT business_id FROM profiles WHERE id = auth.uid()
$$;

-- -----------------------------------------------------------------------------
-- 2. Add business_id columns if not already present
-- -----------------------------------------------------------------------------

ALTER TABLE sales    ADD COLUMN IF NOT EXISTS business_id UUID REFERENCES profiles(business_id);
ALTER TABLE products ADD COLUMN IF NOT EXISTS business_id UUID;
ALTER TABLE variants ADD COLUMN IF NOT EXISTS business_id UUID;

-- -----------------------------------------------------------------------------
-- 3. Enable Row Level Security on all affected tables
-- -----------------------------------------------------------------------------

ALTER TABLE sales     ENABLE ROW LEVEL SECURITY;
ALTER TABLE products  ENABLE ROW LEVEL SECURITY;
ALTER TABLE variants  ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles  ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------------------------------
-- 4. Drop existing policies (idempotent re-run safety)
-- -----------------------------------------------------------------------------

DROP POLICY IF EXISTS "sales_select"   ON sales;
DROP POLICY IF EXISTS "sales_insert"   ON sales;
DROP POLICY IF EXISTS "sales_update"   ON sales;
DROP POLICY IF EXISTS "sales_delete"   ON sales;

DROP POLICY IF EXISTS "products_select" ON products;
DROP POLICY IF EXISTS "products_insert" ON products;
DROP POLICY IF EXISTS "products_update" ON products;
DROP POLICY IF EXISTS "products_delete" ON products;

DROP POLICY IF EXISTS "variants_select" ON variants;
DROP POLICY IF EXISTS "variants_insert" ON variants;
DROP POLICY IF EXISTS "variants_update" ON variants;

DROP POLICY IF EXISTS "profiles_select" ON profiles;

-- -----------------------------------------------------------------------------
-- 5. RLS policies for: sales
-- -----------------------------------------------------------------------------

-- SELECT: all authenticated users, own business only
CREATE POLICY "sales_select"
  ON sales FOR SELECT
  TO authenticated
  USING (business_id = get_my_business_id());

-- INSERT: admin or cashier, own business only
CREATE POLICY "sales_insert"
  ON sales FOR INSERT
  TO authenticated
  WITH CHECK (
    business_id = get_my_business_id()
    AND get_my_role() IN ('admin', 'cashier')
  );

-- UPDATE: admin only, own business only
CREATE POLICY "sales_update"
  ON sales FOR UPDATE
  TO authenticated
  USING (
    business_id = get_my_business_id()
    AND get_my_role() = 'admin'
  )
  WITH CHECK (
    business_id = get_my_business_id()
    AND get_my_role() = 'admin'
  );

-- DELETE: admin only, own business only
CREATE POLICY "sales_delete"
  ON sales FOR DELETE
  TO authenticated
  USING (
    business_id = get_my_business_id()
    AND get_my_role() = 'admin'
  );

-- -----------------------------------------------------------------------------
-- 6. RLS policies for: products
-- -----------------------------------------------------------------------------

-- SELECT: all authenticated users, own business only
CREATE POLICY "products_select"
  ON products FOR SELECT
  TO authenticated
  USING (business_id = get_my_business_id());

-- INSERT: admin or manager, own business only
CREATE POLICY "products_insert"
  ON products FOR INSERT
  TO authenticated
  WITH CHECK (
    business_id = get_my_business_id()
    AND get_my_role() IN ('admin', 'manager')
  );

-- UPDATE: admin or manager, own business only
CREATE POLICY "products_update"
  ON products FOR UPDATE
  TO authenticated
  USING (
    business_id = get_my_business_id()
    AND get_my_role() IN ('admin', 'manager')
  )
  WITH CHECK (
    business_id = get_my_business_id()
    AND get_my_role() IN ('admin', 'manager')
  );

-- DELETE: admin only, own business only
CREATE POLICY "products_delete"
  ON products FOR DELETE
  TO authenticated
  USING (
    business_id = get_my_business_id()
    AND get_my_role() = 'admin'
  );

-- -----------------------------------------------------------------------------
-- 7. RLS policies for: variants
-- -----------------------------------------------------------------------------

-- SELECT: all authenticated users, own business only
CREATE POLICY "variants_select"
  ON variants FOR SELECT
  TO authenticated
  USING (business_id = get_my_business_id());

-- INSERT: admin or manager, own business only
CREATE POLICY "variants_insert"
  ON variants FOR INSERT
  TO authenticated
  WITH CHECK (
    business_id = get_my_business_id()
    AND get_my_role() IN ('admin', 'manager')
  );

-- UPDATE: admin or manager, own business only
CREATE POLICY "variants_update"
  ON variants FOR UPDATE
  TO authenticated
  USING (
    business_id = get_my_business_id()
    AND get_my_role() IN ('admin', 'manager')
  )
  WITH CHECK (
    business_id = get_my_business_id()
    AND get_my_role() IN ('admin', 'manager')
  );

-- -----------------------------------------------------------------------------
-- 8. RLS policies for: profiles
-- -----------------------------------------------------------------------------

-- SELECT: a user can see their own row, OR an admin can see all rows in their business
CREATE POLICY "profiles_select"
  ON profiles FOR SELECT
  TO authenticated
  USING (
    id = auth.uid()
    OR (
      get_my_role() = 'admin'
      AND business_id = get_my_business_id()
    )
  );
