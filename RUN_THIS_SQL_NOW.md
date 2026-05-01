# 🚨 RUN THIS SQL NOW - Fix Brand Creation Error

## The Problem
Error: "new row violates row-level security policy for table 'brands'"

This means the database security policies are blocking brand creation.

## The Solution
Run the SQL script to:
1. ✓ Fix security policies for brands and categories
2. ✓ Add pre-installed brands (Samsung, Apple, Huawei, Google Pixel, HP, Lenovo, Toshiba)
3. ✓ Add pre-installed categories (Phone, Accessories, Laptops, Laptop Accessories)
4. ✓ Keep ability to add more brands/categories in the future

## Steps to Fix

### 1. Open Supabase SQL Editor
- Go to your Supabase Dashboard
- Click "SQL Editor" in the left sidebar
- Click "New Query"

### 2. Copy and Run the SQL
Open the file `FIX_RLS_AND_ADD_BRANDS.sql` and copy ALL the content, then paste it into the SQL Editor and click "Run".

**OR** copy this shorter version:

```sql
-- Fix RLS Policies
ALTER TABLE brands ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable read access for all users" ON brands;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON brands;
CREATE POLICY "Enable read access for all users" ON brands FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON brands FOR INSERT WITH CHECK (true);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable read access for all users" ON categories;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON categories;
CREATE POLICY "Enable read access for all users" ON categories FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON categories FOR INSERT WITH CHECK (true);

-- Add condition column
ALTER TABLE products ADD COLUMN IF NOT EXISTS condition TEXT DEFAULT 'brand_new' CHECK (condition IN ('brand_new', 'pre_owned'));

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

### 3. Verify Success
You should see messages like:
- "Success. No rows returned"
- Or a table showing the brands and categories created

### 4. Test Adding a Product
1. Refresh your app page (Ctrl+F5)
2. Go to Products
3. Click "Add Product"
4. Type a brand name (try "Samsung" or "Apple" - should auto-complete)
5. Type a category (try "Phone" - should auto-complete)
6. Select condition (Brand New or Pre-owned)
7. Fill other fields
8. Click "Create Product"

Should work now! ✓

## What This Does

### Pre-installed Brands:
- **Phones**: Samsung, Apple, Huawei, Google Pixel
- **Laptops**: HP, Lenovo, Toshiba, Apple

### Pre-installed Categories:
- Phone
- Accessories
- Laptops
- Laptop Accessories

### You Can Still:
- Type any brand name (will auto-create if new)
- Type any category name (will auto-create if new)
- The pre-installed ones just make it faster!

## If It Still Doesn't Work

1. Check you're logged in
2. Check browser console (F12) for errors
3. Make sure the SQL ran successfully
4. Try logging out and back in
5. Clear browser cache (Ctrl+Shift+Delete)
