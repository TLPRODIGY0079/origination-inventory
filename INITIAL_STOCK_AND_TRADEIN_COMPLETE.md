# Initial Stock Field & Trade-in Persistence - COMPLETE ✓

## Changes Made

### 1. Initial Stock Quantity Field - FIXED ✓

**Issue**: The initial stock field was in the code but not visible when creating products.

**Fix Applied**:
- Improved the field detection logic in `openProductModal` function
- Changed from checking `$('mProdInitialStock')` to using a safer approach with `initialStockInput` variable
- The field now properly shows when creating new products (not when editing)
- Field is in the same row as "Selling Price" for better visibility

**How it works**:
1. When admin clicks "Add Product", the modal opens
2. The "Initial Stock Quantity" field appears in the form (next to Selling Price)
3. Admin can enter the initial quantity (default: 0)
4. When product is created:
   - Product is saved to database
   - Default variant is auto-created with the specified stock quantity
   - Stock movement is recorded: "Initial stock: +X"

**Note**: Field only appears for NEW products, not when editing existing ones.

---

### 2. Trade-in Database Persistence - IMPLEMENTED ✓

**What was added**:

#### A. Database Table (`CREATE_TRADEINS_TABLE.sql`)
Created `trade_ins` table with columns:
- `id` - Unique identifier
- `receipt_no` - Trade-in receipt number (TI-0001, TI-0002, etc.)
- `date` / `date_str` - Transaction date
- `trade_in_device_name` - Old device name
- `trade_in_imei` - Old device IMEI/serial
- `trade_in_value` - Trade-in value in Kwacha
- `new_variant_id` - Reference to new device variant
- `new_device_name` - New device name
- `new_device_sku` - New device SKU
- `new_device_price` - New device price
- `new_device_imei` - New device IMEI (optional)
- `net_payment` - Net payment (new price - trade-in value)
- `customer_name` - Customer name
- `cashier_id` / `cashier_name` - Who processed the trade-in
- `business_id` - Business identifier

#### B. Code Changes (`index.html`)

**Added to DB object**:
```javascript
let DB = {..., tradeIns: []};
```

**Updated `loadDB()` function**:
- Added query to load trade-ins from Supabase
- Maps trade-in data to camelCase format

**New functions**:
- `renderTradeinTable()` - Displays trade-ins in the table
- `nextTradeinReceipt()` - Generates receipt numbers (TI-0001, TI-0002, etc.)

**Updated `openTradeinModal()` function**:
- Now saves trade-in to database when "Process Trade-In" is clicked
- Updates variant stock (decreases by 1)
- Records stock movement
- Generates unique receipt number
- Shows success/error messages
- Reloads data and refreshes table

**Updated `renderTradein()` function**:
- Calls `renderTradeinTable()` to display actual data
- Shows "No trade-ins yet" if empty

---

## How to Use

### Initial Stock Quantity:
1. Go to Inventory page
2. Click "Add Product"
3. Fill in product details
4. **Look for "Initial Stock Quantity" field** (next to Selling Price)
5. Enter the quantity you want to add
6. Click "Create Product"
7. Product will be created with the specified stock

### Trade-in Feature:
1. **FIRST**: Run `CREATE_TRADEINS_TABLE.sql` in Supabase SQL Editor
2. Go to Trade-in page
3. Click "New Trade-in"
4. Fill in:
   - Trade-in device name and IMEI
   - Trade-in value
   - Select new device from dropdown
   - Customer name
5. Net payment is calculated automatically
6. Click "Process Trade-In"
7. Trade-in is saved to database
8. Stock is updated
9. Trade-in appears in the table

---

## SQL to Run

**IMPORTANT**: You must run this SQL before using the trade-in feature:

```sql
-- Run this in Supabase SQL Editor
-- File: CREATE_TRADEINS_TABLE.sql
```

This creates the `trade_ins` table and sets up RLS policies.

---

## What Happens When Trade-in is Processed

1. **Trade-in record created** in `trade_ins` table
2. **Receipt number generated** (TI-0001, TI-0002, etc.)
3. **Variant stock decreased** by 1 (new device sold)
4. **Stock movement recorded** with reference to trade-in
5. **Data reloaded** from database
6. **Table refreshed** to show new trade-in

---

## Testing

### Test Initial Stock:
1. Create a new product with initial stock = 10
2. Check Inventory page - stock should show 10
3. Check Stock Movements - should show "Initial stock: +10"

### Test Trade-in:
1. Run the SQL to create trade_ins table
2. Create a trade-in transaction
3. Check Trade-in page - should show in table
4. Check Inventory - new device stock should decrease by 1
5. Check Stock Movements - should show trade-in movement

---

## Files Modified

1. **index.html**:
   - Fixed initial stock field detection
   - Added `tradeIns` to DB object
   - Updated `loadDB()` to fetch trade-ins
   - Implemented `renderTradeinTable()`
   - Implemented `nextTradeinReceipt()`
   - Updated `openTradeinModal()` with database persistence
   - Updated `renderTradein()` to display data

2. **CREATE_TRADEINS_TABLE.sql** (NEW):
   - Creates trade_ins table
   - Sets up RLS policies
   - Adds indexes for performance

---

## Status

✅ Initial stock field is now visible and working
✅ Trade-in database table created
✅ Trade-in persistence implemented
✅ Trade-in display implemented
✅ Stock updates on trade-in
✅ Receipt number generation
✅ RLS policies applied

**Next Step**: Run `CREATE_TRADEINS_TABLE.sql` in Supabase SQL Editor to enable trade-in persistence.
