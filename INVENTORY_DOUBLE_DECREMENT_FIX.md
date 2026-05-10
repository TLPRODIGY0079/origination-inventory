# Inventory Double Decrement Bug - FIXED ✓

## Problem

When making a sale:
- **Expected**: If 7 items in inventory and 1 item sold → 6 items remaining
- **Actual**: If 7 items in inventory and 1 item sold → 5 items remaining (2 items removed!)

## Root Cause

The `completeSale` function was updating inventory **twice**:

### First Update (Optimistic - Local)
```javascript
// Line 1013-1014: Updates local DB object
const v=getVariant(si.variant_id);
if(v)v.qty=Math.max(0,(Number(v.qty)||0)-si.qty)
```

### Second Update (Database)
```javascript
// Line 1020-1021: PROBLEM - Uses already-decreased local value!
const v=getVariant(si.variant_id);  // ← Gets ALREADY decreased qty
if(v)await supabaseClient.from('variants').update({qty:Math.max(0,(Number(v.qty)||0)-si.qty)}).eq('id',si.variant_id)
```

**Example**:
1. Start: 7 items in database
2. Local update: 7 - 1 = 6 (local DB now shows 6)
3. Database update: Gets local value (6), then 6 - 1 = 5 ❌
4. Result: Database has 5 instead of 6!

## Solution

Changed the database update to fetch the **current quantity directly from the database** instead of using the already-decreased local value:

```javascript
// Fetch current quantity from database to avoid double-decrement
const{data:currentVariant}=await supabaseClient.from('variants').select('qty').eq('id',si.variant_id).single();
if(currentVariant){
  const newQty=Math.max(0,(Number(currentVariant.qty)||0)-si.qty);
  await supabaseClient.from('variants').update({qty:newQty}).eq('id',si.variant_id);
}
```

**Now**:
1. Start: 7 items in database
2. Local update: 7 - 1 = 6 (local DB shows 6)
3. Database update: Fetches from database (7), then 7 - 1 = 6 ✓
4. Result: Database correctly has 6!

## What Changed

**File**: `index.html`

**Function**: `completeSale()`

**Change**: In the database update section, replaced:
```javascript
const v=getVariant(si.variant_id);
if(v)await supabaseClient.from('variants').update({qty:Math.max(0,(Number(v.qty)||0)-si.qty)}).eq('id',si.variant_id)
```

With:
```javascript
const{data:currentVariant}=await supabaseClient.from('variants').select('qty').eq('id',si.variant_id).single();
if(currentVariant){
  const newQty=Math.max(0,(Number(currentVariant.qty)||0)-si.qty);
  await supabaseClient.from('variants').update({qty:newQty}).eq('id',si.variant_id);
}
```

## Testing

### Before Fix:
1. Product has 7 items
2. Sell 1 item
3. Check inventory → Shows 5 items ❌ (2 removed)

### After Fix:
1. Product has 7 items
2. Sell 1 item
3. Check inventory → Shows 6 items ✓ (1 removed)

## Why This Happened

The code was doing an "optimistic update" (updating local data immediately for better UX) but then using that already-updated local data when calculating the database update, causing a double decrement.

## Status

✅ Fixed - Inventory now correctly decrements by the exact quantity sold
✅ No more double decrement
✅ Database query ensures accurate quantity

The fix is live in `index.html`. Test by making a sale and verifying the inventory decreases by the correct amount.
