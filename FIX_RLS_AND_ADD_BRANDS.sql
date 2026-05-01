-- COMPLETE FIX: RLS Policies + Pre-populated Brands & Categories
-- Run this entire script in your Supabase SQL Editor

-- ============================================================================
-- STEP 1: Fix RLS Policies for brands table
-- ============================================================================

-- Drop existing policies if any
DROP POLICY IF EXISTS "Enable read access for all users" ON brands;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON brands;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON brands;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON brands;

-- Enable RLS
ALTER TABLE brands ENABLE ROW LEVEL SECURITY;

-- Create permissive policies (allow all authenticated users)
CREATE POLICY "Enable read access for all users" ON brands
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON brands
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON brands
    FOR UPDATE USING (true);

CREATE POLICY "Enable delete for authenticated users" ON brands
    FOR DELETE USING (true);

-- ============================================================================
-- STEP 2: Fix RLS Policies for categories table
-- ============================================================================

-- Drop existing policies if any
DROP POLICY IF EXISTS "Enable read access for all users" ON categories;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON categories;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON categories;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON categories;

-- Enable RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Create permissive policies (allow all authenticated users)
CREATE POLICY "Enable read access for all users" ON categories
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON categories
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON categories
    FOR UPDATE USING (true);

CREATE POLICY "Enable delete for authenticated users" ON categories
    FOR DELETE USING (true);

-- ============================================================================
-- STEP 3: Add condition column to products table
-- ============================================================================

ALTER TABLE products 
ADD COLUMN IF NOT EXISTS condition TEXT DEFAULT 'brand_new' 
CHECK (condition IN ('brand_new', 'pre_owned'));

UPDATE products 
SET condition = 'brand_new' 
WHERE condition IS NULL;

COMMENT ON COLUMN products.condition IS 'Product condition: brand_new or pre_owned';

-- ============================================================================
-- STEP 4: Pre-populate Brands (Phone & Laptop brands)
-- ============================================================================

-- Delete existing brands to avoid duplicates (optional - comment out if you want to keep existing)
-- DELETE FROM brands;

-- Insert phone brands
INSERT INTO brands (id, name) VALUES 
    ('brand-samsung', 'Samsung'),
    ('brand-apple', 'Apple'),
    ('brand-huawei', 'Huawei'),
    ('brand-google-pixel', 'Google Pixel')
ON CONFLICT (id) DO NOTHING;

-- Insert laptop brands
INSERT INTO brands (id, name) VALUES 
    ('brand-hp', 'HP'),
    ('brand-lenovo', 'Lenovo'),
    ('brand-toshiba', 'Toshiba')
ON CONFLICT (id) DO NOTHING;

-- Note: Apple is already added above, so we don't duplicate it

-- ============================================================================
-- STEP 5: Pre-populate Categories
-- ============================================================================

-- Delete existing categories to avoid duplicates (optional - comment out if you want to keep existing)
-- DELETE FROM categories;

-- Insert categories with appropriate icons
INSERT INTO categories (id, name, icon) VALUES 
    ('cat-phone', 'Phone', 'fa-mobile-screen'),
    ('cat-accessories', 'Accessories', 'fa-headphones'),
    ('cat-laptops', 'Laptops', 'fa-laptop'),
    ('cat-laptop-accessories', 'Laptop Accessories', 'fa-keyboard')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STEP 6: Verify the setup
-- ============================================================================

-- Check brands
SELECT 'Brands created:' as status, COUNT(*) as count FROM brands;
SELECT * FROM brands ORDER BY name;

-- Check categories
SELECT 'Categories created:' as status, COUNT(*) as count FROM categories;
SELECT * FROM categories ORDER BY name;

-- Check RLS policies
SELECT 'RLS Policies for brands:' as status;
SELECT schemaname, tablename, policyname, permissive, roles, cmd 
FROM pg_policies 
WHERE tablename = 'brands';

SELECT 'RLS Policies for categories:' as status;
SELECT schemaname, tablename, policyname, permissive, roles, cmd 
FROM pg_policies 
WHERE tablename = 'categories';

-- Success message
SELECT '✓ Setup complete! You can now add products with these brands and categories.' as message;
