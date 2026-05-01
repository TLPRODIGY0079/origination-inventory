-- ============================================================================
-- COMPLETE DATABASE FIX - Add ALL Missing Columns
-- Run this ENTIRE script in your Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- STEP 1: Fix products table - Add missing columns
-- ============================================================================

-- Add cost column (if missing)
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS cost DECIMAL(10,2) DEFAULT 0;

-- Add condition column (if missing)
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS condition TEXT DEFAULT 'brand_new' 
CHECK (condition IN ('brand_new', 'pre_owned'));

-- Add business_id column (if missing)
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS business_id UUID;

-- Update existing products
UPDATE products 
SET condition = 'brand_new' 
WHERE condition IS NULL;

UPDATE products 
SET cost = 0 
WHERE cost IS NULL;

-- ============================================================================
-- STEP 2: Fix brands table - Add missing columns
-- ============================================================================

ALTER TABLE brands 
ADD COLUMN IF NOT EXISTS business_id UUID;

-- ============================================================================
-- STEP 3: Fix catego
ries table - Add missing columns
-- ============================================================================

ALTER TABLE categories 
ADD COLUMN IF NOT EXISTS business_id UUID;

-- ============================================================================
-- STEP 4: Fix variants table - Add missing columns
-- ============================================================================

ALTER TABLE variants 
ADD COLUMN IF NOT EXISTS business_id UUID;

ALTER TABLE variants 
ADD COLUMN IF NOT EXISTS cost DECIMAL(10,2) DEFAULT 0;

-- ============================================================================
-- STEP 5: Fix RLS Policies for brands
-- ============================================================================

ALTER TABLE brands ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for all users" ON brands;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON brands;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON brands;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON brands;

CREATE POLICY "Enable read access for all users" ON brands
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON brands
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON brands
    FOR UPDATE USING (true);

CREATE POLICY "Enable delete for authenticated users" ON brands
    FOR DELETE USING (true);

-- ============================================================================
-- STEP 6: Fix RLS Policies for categories
-- ============================================================================

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for all users" ON categories;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON categories;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON categories;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON categories;

CREATE POLICY "Enable read access for all users" ON categories
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON categories
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON categories
    FOR UPDATE USING (true);

CREATE POLICY "Enable delete for authenticated users" ON categories
    FOR DELETE USING (true);

-- ============================================================================
-- STEP 7: Pre-populate Brands
-- ============================================================================

INSERT INTO brands (id, name) VALUES 
    ('brand-samsung', 'Samsung'),
    ('brand-apple', 'Apple'),
    ('brand-huawei', 'Huawei'),
    ('brand-google-pixel', 'Google Pixel'),
    ('brand-hp', 'HP'),
    ('brand-lenovo', 'Lenovo'),
    ('brand-toshiba', 'Toshiba')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STEP 8: Pre-populate Categories
-- ============================================================================

INSERT INTO categories (id, name, icon) VALUES 
    ('cat-phone', 'Phone', 'fa-mobile-screen'),
    ('cat-accessories', 'Accessories', 'fa-headphones'),
    ('cat-laptops', 'Laptops', 'fa-laptop'),
    ('cat-laptop-accessories', 'Laptop Accessories', 'fa-keyboard')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STEP 9: Add comments to columns
-- ============================================================================

COMMENT ON COLUMN products.cost IS 'Cost price of the product';
COMMENT ON COLUMN products.condition IS 'Product condition: brand_new or pre_owned';
COMMENT ON COLUMN products.business_id IS 'Business ID for multi-tenant support';
COMMENT ON COLUMN brands.business_id IS 'Business ID for multi-tenant support';
COMMENT ON COLUMN categories.business_id IS 'Business ID for multi-tenant support';
COMMENT ON COLUMN variants.business_id IS 'Business ID for multi-tenant support';
COMMENT ON COLUMN variants.cost IS 'Cost price of the variant';

-- ============================================================================
-- STEP 10: Verify the setup
-- ============================================================================

-- Check products table structure
SELECT 'Products table columns:' as status;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'products'
ORDER BY ordinal_position;

-- Check brands
SELECT 'Brands created:' as status, COUNT(*) as count FROM brands;

-- Check categories
SELECT 'Categories created:' as status, COUNT(*) as count FROM categories;

-- Success message
SELECT '✓✓✓ COMPLETE! All columns added, RLS fixed, brands and categories populated.' as message;
SELECT '✓✓✓ You can now add products!' as message;
