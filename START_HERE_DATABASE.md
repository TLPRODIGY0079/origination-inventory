# 🚀 Quick Start - Database Setup

## You're Almost There!

✅ Authentication works - you logged in successfully!
❌ Database is empty - that's why you see the login screen again

## Fix It In 2 Minutes

### Step 1: Open Supabase SQL Editor
Click this link:
```
https://app.supabase.com/project/ydogahzvieaunitxaoim/sql/new
```

### Step 2: Copy & Paste
1. Open the file: `QUICK_SETUP.sql` (in your project root)
2. Copy the ENTIRE file (it's been updated with the correct schema)
3. Paste it into the Supabase SQL Editor
4. Click "Run" (or press Ctrl+Enter)

### Step 3: Refresh Your App
1. Go back to your app
2. Press `Ctrl + Shift + R` to hard refresh
3. You should now see the dashboard with no errors!

## Already Ran QUICK_SETUP.sql Before?

If you already ran the old version, you need to add missing columns:
1. Open the file: `supabase/migrations/003_add_missing_columns.sql`
2. Copy and paste it into Supabase SQL Editor
3. Click "Run"
4. Refresh your app

See `FIX_400_ERRORS.md` for details.

## That's It!

Your database is now set up with:
- ✅ All tables created
- ✅ Security policies enabled
- ✅ Your admin profile created
- ✅ Default categories and brands

## What's Next?

1. Add your first product (Products page)
2. Make your first sale (POS page)
3. View analytics (Dashboard)

## Troubleshooting

**Still seeing errors?**
- Make sure the SQL ran successfully (check for green "Success" message)
- Clear browser cache: Ctrl+Shift+R
- Check browser console for specific errors

**Need to verify tables exist?**
Go to: https://app.supabase.com/project/ydogahzvieaunitxaoim/editor
You should see all these tables:
- profiles
- products
- variants
- sales
- categories
- brands
- etc.

## Files Reference

- `QUICK_SETUP.sql` - Run this in Supabase (ONE file, does everything)
- `SUPABASE_SETUP_COMPLETE.md` - Detailed explanation
- `supabase/migrations/` - Individual migration files (if you prefer step-by-step)
