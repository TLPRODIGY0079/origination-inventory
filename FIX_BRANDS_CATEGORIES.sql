-- Fix for brands and categories tables
-- Run this in your Supabase SQL Editor

-- Add business_id column to brands table (optional, for future multi-tenant support)
ALTER TABLE brands 
ADD COLUMN IF NOT EXISTS business_id UUID;

-- Add business_id column to categories table (optional, for future multi-tenant support)
ALTER TABLE categories 
ADD COLUMN IF NOT EXISTS business_id UUID;

-- Add condition column to products table
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS condition TEXT DEFAULT 'brand_new' 
CHECK (condition IN ('brand_new', 'pre_owned'));

-- Update existing products to have default condition
UPDATE products 
SET condition = 'brand_new' 
WHERE condition IS NULL;

-- Add comments
COMMENT ON COLUMN brands.business_id IS 'Optional: Business ID for multi-tenant support';
COMMENT ON COLUMN categories.business_id IS 'Optional: Business ID for multi-tenant support';
COMMENT ON COLUMN products.condition IS 'Product condition: brand_new or pre_owned';

-- Verify the changes
SELECT 'Brands table updated' as status;
SELECT 'Categories table updated' as status;
SELECT 'Products table updated with condition column' as status;
