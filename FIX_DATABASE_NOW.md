# Fix Database Error - URGENT ⚠️

## Problem
Getting error: "Could not find the 'business_id' column of 'brands' in the schema cache"

## Solution
The `brands` and `categories` tables are missing the `business_id` column. I've updated the code to work without it, but you should add these columns for future compatibility.

## Quick Fix - Run This SQL Now

1. Go to your Supabase Dashboard
2. Click on "SQL Editor"
3. Click "New Query"
4. Copy and paste this SQL:

```sql
-- Add business_id column to brands table
ALTER TABLE brands 
ADD COLUMN IF NOT EXISTS business_id UUID;

-- Add business_id column to categories table
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
```

5. Click "Run" or press Ctrl+Enter

## What I Fixed in the Code

✓ Removed `business_id` from brand creation
✓ Removed `business_id` from category creation
✓ Product creation still uses `business_id` (already exists in products table)

## Test After Running SQL

1. Try adding a new product
2. Enter a brand name (e.g., "Apple")
3. Enter a category (e.g., "Phone")
4. Select condition (Brand New or Pre-owned)
5. Fill in other fields
6. Click "Create Product"

It should work now!

## What These Columns Do

- **business_id in brands**: Allows multiple businesses to have their own brands (future feature)
- **business_id in categories**: Allows multiple businesses to have their own categories (future feature)
- **condition in products**: Tracks if products are Brand New or Pre-owned

## If You Still Get Errors

If you still see errors after running the SQL:

1. Check the error message in browser console (F12)
2. Make sure you're logged in with a user that has `business_id` set
3. Try refreshing the page (Ctrl+F5)
4. Check that the SQL ran successfully (should see "Success" message)

## Files Created

- `FIX_BRANDS_CATEGORIES.sql` - The SQL migration file
- `FIX_DATABASE_NOW.md` - This instruction file
