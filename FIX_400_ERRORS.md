# Fix 400 Errors - Add Missing Columns

## What's Happening

The app is loading successfully! 🎉

The 400 errors you're seeing are because the database schema is missing some columns that the code expects:
- `date_str` (string version of date)
- `total_amount` (copy of total)
- `cashier_name` (cashier's name)
- `items` (number of items in sale)
- `discount` (discount amount)

## Quick Fix (2 Options)

### Option A: If You Haven't Run QUICK_SETUP.sql Yet
The `QUICK_SETUP.sql` file has been updated with the correct schema. Just run it as instructed in `START_HERE_DATABASE.md`.

### Option B: If You Already Ran QUICK_SETUP.sql
Run this additional migration to add the missing columns:

1. Open Supabase SQL Editor:
   ```
   https://app.supabase.com/project/ydogahzvieaunitxaoim/sql/new
   ```

2. Copy and paste the entire content of:
   ```
   supabase/migrations/003_add_missing_columns.sql
   ```

3. Click "Run"

4. Refresh your app (Ctrl+Shift+R)

## What This Does

The migration:
1. Adds the missing columns to the `sales` table
2. Creates triggers to auto-populate `date_str` and `total_amount`
3. Backfills any existing data

## After Running

The 400 errors will disappear and you'll see:
- ✅ Dashboard loads with stats
- ✅ Charts render correctly
- ✅ Sales history works
- ✅ Export functions work

## Why This Happened

The original schema used:
- `date` (TIMESTAMPTZ)
- `total` (NUMERIC)

But the frontend code expects:
- `date_str` (TEXT) for easier date filtering
- `total_amount` (NUMERIC) for consistency
- `cashier_name` (TEXT) to avoid joins

The updated schema includes both for compatibility.

## Verification

After running the migration, check that these columns exist:

```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'sales' 
ORDER BY column_name;
```

You should see:
- business_id
- cashier_id
- cashier_name ✅ NEW
- created_at
- customer_name
- customer_phone
- date
- date_str ✅ NEW
- discount ✅ NEW
- id
- items ✅ NEW
- payment_method
- receipt_no
- total
- total_amount ✅ NEW

## Next Steps

Once the columns are added:
1. Dashboard will show "0" for all stats (normal - no sales yet)
2. Add products via Products page
3. Make your first sale via POS page
4. Watch the dashboard populate!
