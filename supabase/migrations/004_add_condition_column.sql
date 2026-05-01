-- Add condition column to products table
-- This allows tracking whether products are brand new or pre-owned

ALTER TABLE products 
ADD COLUMN IF NOT EXISTS condition TEXT DEFAULT 'brand_new' CHECK (condition IN ('brand_new', 'pre_owned'));

-- Add comment to explain the column
COMMENT ON COLUMN products.condition IS 'Product condition: brand_new or pre_owned';

-- Update existing products to have default condition
UPDATE products 
SET condition = 'brand_new' 
WHERE condition IS NULL;
