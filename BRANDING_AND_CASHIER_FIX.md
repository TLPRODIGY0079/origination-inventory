# Branding Updates & Cashier Access Fix ✓

## Changes Made

### 1. Receipt Branding ✓
- **Changed**: "STOREVAULT" → "ORIGINATION STORES"
- **Removed**: "Grocery Inventory & POS" subtitle
- **Result**: Clean receipt with just store name and date

### 2. Sidebar Branding ✓
- **Removed**: "Retail & Grocery POS" subtitle under logo
- **Result**: Cleaner sidebar with just "Origination-Inventory"

### 3. Page Title ✓
- **Changed**: "Grocery Inventory & POS" → "POS System"

## Cashier Access Issue

### Problem
Cashiers cannot see products when logged in because RLS (Row-Level Security) policies are blocking read access.

### Solution
Run this SQL to allow all authenticated users to read products:

```sql
-- Fix products table RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable read access for all users" ON products;
CREATE POLICY "Enable read access for all users" ON products FOR SELECT USING (true);

-- Fix variants table RLS  
ALTER TABLE variants ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable read access for all users" ON variants;
CREATE POLICY "Enable read access for all users" ON variants FOR SELECT USING (true);

-- Fix serialized_items table RLS
ALTER TABLE serialized_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable read access for all users" ON serialized_items;
CREATE POLICY "Enable read access for all users" ON serialized_items FOR SELECT USING (true);
```

## After Running the SQL

### Cashiers Will Be Able To:
✓ See all products in the POS
✓ Add products to cart
✓ Complete sales
✓ View sales history

### Cashiers Will NOT Be Able To:
✗ Add/edit/delete products (admin only)
✗ Manage inventory (admin/manager only)
✗ Access reports (admin/manager only)
✗ Manage users (admin only)

## Test It

1. **Run the SQL** in Supabase SQL Editor
2. **Log in as cashier**
3. **Go to Sales / POS page**
4. **You should now see products!**
5. **Try adding a product to cart**
6. **Complete a sale**

## Receipt Preview

Before:
```
STOREVAULT
Grocery Inventory & POS
5/1/2026, 10:30:00 AM
```

After:
```
ORIGINATION STORES
5/1/2026, 10:30:00 AM
```

Much cleaner! ✓
