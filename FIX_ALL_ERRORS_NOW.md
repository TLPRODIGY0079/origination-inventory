# 🚨 FIX ALL DATABASE ERRORS - RUN THIS NOW

## Current Error
"Could not find the 'cost' column of 'products' in the schema cache"

## Root Cause
Your database is missing several required columns in multiple tables.

## The Complete Fix

### Run This ONE SQL Script

Open `COMPLETE_DATABASE_FIX.sql` and run the ENTIRE script in your Supabase SQL Editor.

**OR** copy and paste this complete script:

```sql
-- Add missing columns to products table
ALTER TABLE products ADD COLUMN IF NOT EXISTS cost DECIMAL(10,2) DEFAULT 0;
ALTER TABLE products ADD COLUMN IF NOT EXISTS condition TEXT DEFAULT 'brand_new' CHECK (condition IN ('brand_new', 'pre_owned'));
ALTER TABLE products ADD COLUMN IF NOT EXISTS business_id UUID;

-- Add missing columns to brands table
ALTER TABLE brands ADD COLUMN IF NOT EXISTS business_id UUID;

-- Add missing columns to categories table
ALTER TABLE categories ADD COLUMN IF NOT EXISTS business_id UUID;

-- Add missing columns to variants table
ALTER TABLE variants ADD COLUMN IF NOT EXISTS business_id UUID;
ALTER TABLE variants ADD COLUMN IF NOT EXISTS cost DECIMAL(10,2) DEFAULT 0;

-- Fix RLS for brands
ALTER TABLE brands ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON brands;
CREATE POLICY "Enable insert for authenticated users" ON brands FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Enable read access for all users" ON brands;
CREATE POLICY "Enable read access for all users" ON brands FOR SELECT USING (true);

-- Fix RLS for categories
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON categories;
CREATE POLICY "Enable insert for authenticated users" ON categories FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Enable read access for all users" ON categories;
CREATE POLICY "Enable read access for all users" ON categories FOR SELECT USING (true);

-- Add brands
INSERT INTO brands (id, name) VALUES 
    ('brand-samsung', 'Samsung'),
    ('brand-apple', 'Apple'),
    ('brand-huawei', 'Huawei'),
    ('brand-google-pixel', 'Google Pixel'),
    ('brand-hp', 'HP'),
    ('brand-lenovo', 'Lenovo'),
    ('brand-toshiba', 'Toshiba')
ON CONFLICT (id) DO NOTHING;

-- Add categories
INSERT INTO categories (id, name, icon) VALUES 
    ('cat-phone', 'Phone', 'fa-mobile-screen'),
    ('cat-accessories', 'Accessories', 'fa-headphones'),
    ('cat-laptops', 'Laptops', 'fa-laptop'),
    ('cat-laptop-accessories', 'Laptop Accessories', 'fa-keyboard')
ON CONFLICT (id) DO NOTHING;
```

## What This Fixes

### ✓ Adds Missing Columns:
- `products.cost` - Cost price
- `products.condition` - Brand New or Pre-owned
- `products.business_id` - Business reference
- `brands.business_id` - Business reference
- `categories.business_id` - Business reference
- `variants.business_id` - Business reference
- `variants.cost` - Variant cost price

### ✓ Fixes Security Policies:
- Allows authenticated users to create brands
- Allows authenticated users to create categories

### ✓ Pre-populates Data:
- **Brands**: Samsung, Apple, Huawei, Google Pixel, HP, Lenovo, Toshiba
- **Categories**: Phone, Accessories, Laptops, Laptop Accessories

## Steps

1. **Open Supabase Dashboard**
2. **Click "SQL Editor"**
3. **Click "New Query"**
4. **Copy the SQL above**
5. **Paste and click "Run"**
6. **Wait for "Success" message**
7. **Refresh your app (Ctrl+F5)**
8. **Try adding a product**

## After Running the SQL

Your product form will now work with:
- ✓ Brand field (text input with auto-complete)
- ✓ Category field (text input with auto-complete)
- ✓ Condition field (Brand New / Pre-owned)
- ✓ Cost field (working)
- ✓ All other fields

## Test It

1. Go to Products page
2. Click "Add Product"
3. Fill in:
   - Product Name: "iPhone 15 Pro"
   - Brand: "Apple" (should auto-complete)
   - Category: "Phone" (should auto-complete)
   - Tracking Type: Serialized
   - Unit: pcs
   - Condition: Brand New
   - Reorder Level: 2
   - Cost Price: 25000
   - Selling Price: 31000
   - Description: "256GB Natural Titanium"
4. Click "Create Product"

Should work! ✓

## If You Still Get Errors

Check the browser console (F12) and share the exact error message.
