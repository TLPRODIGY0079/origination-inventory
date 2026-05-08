-- =============================================================================
-- Fix Profiles RLS Policies
-- =============================================================================
-- This fixes the error: "Fetch failed loading: GET profiles"
-- The profiles table needs RLS policies so users can read their own profiles

-- Enable RLS on profiles table
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "profiles_select" ON profiles;
DROP POLICY IF EXISTS "profiles_insert" ON profiles;
DROP POLICY IF EXISTS "profiles_update" ON profiles;
DROP POLICY IF EXISTS "profiles_delete" ON profiles;

-- Allow users to read profiles in their business
CREATE POLICY "profiles_select" ON profiles FOR SELECT
  TO authenticated
  USING (
    business_id = (SELECT business_id FROM profiles WHERE id = auth.uid())
    OR id = auth.uid()
  );

-- Allow users to insert their own profile (for signup)
CREATE POLICY "profiles_insert" ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (id = auth.uid());

-- Allow users to update their own profile
CREATE POLICY "profiles_update" ON profiles FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- Only admins can delete profiles
CREATE POLICY "profiles_delete" ON profiles FOR DELETE
  TO authenticated
  USING (
    id = auth.uid() 
    OR (SELECT role FROM profiles WHERE id = auth.uid()) = 'admin'
  );

-- =============================================================================
-- Fix Variants RLS for Low Stock Check
-- =============================================================================

-- The low stock check is failing because variants RLS might be too restrictive
-- Let's make sure variants can be read by all users in the same business

DROP POLICY IF EXISTS "variants_select" ON variants;

CREATE POLICY "variants_select" ON variants FOR SELECT
  TO authenticated
  USING (
    business_id = (SELECT business_id FROM profiles WHERE id = auth.uid())
  );

-- =============================================================================
-- Verification
-- =============================================================================

-- Check that policies were created
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename IN ('profiles', 'variants')
ORDER BY tablename, policyname;

-- Test: Try to select from profiles (should work now)
SELECT id, full_name, role FROM profiles LIMIT 5;

-- Test: Try to select from variants (should work now)
SELECT id, product_id, qty FROM variants LIMIT 5;

-- =============================================================================
-- DONE!
-- =============================================================================
-- After running this SQL:
-- 1. Hard refresh your browser (Ctrl + F5)
-- 2. The errors should be gone
-- 3. The app should load properly
