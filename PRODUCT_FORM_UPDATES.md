# Product Form Updates ✓

## Summary
Updated the Add/Edit Product modal with improved fields for better inventory management.

## Changes Made

### 1. Category Field - Changed to Text Input ✓
**Before:** Dropdown with predefined categories
**After:** Text input with auto-creation

**How it works:**
- Admin types category name (e.g., "Phone", "Accessories", "Laptops", "Laptop Accessories")
- System checks if category exists (case-insensitive)
- If new, automatically creates it in the database
- If exists, reuses the existing category
- No more empty dropdowns!

### 2. Unit Field - Simplified Options ✓
**Before:** Multiple options (pcs, kg, bottle, pack, loaf, tin)
**After:** Only 2 options:
- `pcs` - Pieces
- `item` - Item

**Reason:** Simplified for electronics/phone inventory management

### 3. Condition Field - NEW! ✓
Added a new field to track product condition:
- **Brand New** - New, unused products
- **Pre-owned** - Used/refurbished products

**Location:** Appears next to the Unit field
**Database:** Stored in `products.condition` column
**Default:** Brand New

## Form Layout

```
Row 1: [Product Name] [Brand]
Row 2: [Category] [Tracking Type]
Row 3: [Unit] [Condition]
Row 4: [Reorder Level] [Cost Price]
Row 5: [Selling Price] [Description (full width)]
```

## Database Changes

### New Column: `condition`
- **Table:** `products`
- **Type:** TEXT
- **Values:** 'brand_new' or 'pre_owned'
- **Default:** 'brand_new'
- **Migration:** `004_add_condition_column.sql`

### Auto-Creation Support
Both Brand and Category now support auto-creation:
- **brands** table: Auto-creates with `business_id`
- **categories** table: Auto-creates with `business_id` and default icon 'fa-box'

## How to Apply Database Changes

Run this SQL in your Supabase SQL Editor:

```sql
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS condition TEXT DEFAULT 'brand_new' 
CHECK (condition IN ('brand_new', 'pre_owned'));

UPDATE products 
SET condition = 'brand_new' 
WHERE condition IS NULL;
```

Or run the migration file:
```bash
# In Supabase dashboard: SQL Editor > New Query
# Copy and paste contents of: supabase/migrations/004_add_condition_column.sql
```

## Example Usage

### Adding a New Phone:
1. Product Name: "iPhone 15 Pro Max"
2. Brand: "Apple" (auto-created if new)
3. Category: "Phone" (auto-created if new)
4. Tracking Type: Serialized (IMEI/Serial)
5. Unit: pcs
6. Condition: Brand New
7. Reorder Level: 2
8. Cost Price: 25000
9. Selling Price: 31000
10. Description: "256GB Natural Titanium"

### Adding Pre-owned Laptop:
1. Product Name: "MacBook Pro 14"
2. Brand: "Apple"
3. Category: "Laptops"
4. Tracking Type: Serialized
5. Unit: item
6. Condition: Pre-owned
7. Cost: 18000
8. Price: 22000

## Benefits

✓ **Flexible Categories** - Add any category on the fly
✓ **No Empty Dropdowns** - Categories auto-populate as you add them
✓ **Simplified Units** - Only relevant options for electronics
✓ **Condition Tracking** - Know which items are new vs used
✓ **Faster Entry** - Type instead of scrolling through dropdowns
✓ **No Duplicates** - Case-insensitive matching prevents duplicate categories

## Testing Checklist

- [ ] Add product with new category "Phone"
- [ ] Add another product with same category (different case) - should reuse
- [ ] Add product with "Accessories" category
- [ ] Add product with "Laptops" category
- [ ] Add product with "Laptop Accessories" category
- [ ] Select "Brand New" condition
- [ ] Select "Pre-owned" condition
- [ ] Verify Unit dropdown only shows "pcs" and "item"
- [ ] Edit existing product and change condition
- [ ] Verify categories appear in category filter dropdown

## Notes

- Categories are created with a default icon 'fa-box'
- You can update category icons later in the database if needed
- The condition field is optional but defaults to "Brand New"
- All changes are backward compatible with existing products
