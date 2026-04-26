# Database Migration Guide

## Origination-Inventory Rebrand Migrations

This directory contains database migration scripts for the Origination-Inventory rebrand.

## Migration Files

1. **001_rls_policies.sql** - Original RLS policies (updated with new branding comments)
2. **002_rebrand_to_origination.sql** - Rebrand migration script

## How to Apply Migrations

### Option 1: Using Supabase CLI (Recommended)

```bash
# Make sure you're in the project root directory
cd /path/to/origination-inventory

# Apply all pending migrations
npx supabase db push

# Or apply a specific migration
npx supabase db push --file supabase/migrations/002_rebrand_to_origination.sql
```

### Option 2: Using Supabase Dashboard

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Copy the contents of `002_rebrand_to_origination.sql`
4. Paste into the SQL Editor
5. Click "Run" to execute the migration

## Migration Validation

After applying the migration, verify the changes:

```sql
-- Check app metadata
SELECT * FROM app_metadata WHERE key IN ('app_name', 'app_version', 'rebrand_date');

-- Verify table comments
SELECT 
    tablename, 
    obj_description((schemaname||'.'||tablename)::regclass) as comment
FROM pg_tables 
WHERE schemaname = 'public'
AND tablename IN ('sales', 'products', 'variants', 'profiles', 'audit_logs');
```

Expected results:
- `app_name` should be "Origination-Inventory"
- `app_version` should be "2.0.0"
- Table comments should reference "Origination-stores"

## Rollback Procedure

If you need to rollback the rebrand migration:

```sql
-- Remove app metadata
DELETE FROM app_metadata 
WHERE key IN ('app_name', 'app_version', 'rebrand_date', 'previous_name');

-- Update table comments back to original (if needed)
COMMENT ON TABLE sales IS 'Sales transactions';
COMMENT ON TABLE products IS 'Product catalog';
-- ... etc
```

## Important Notes

- **Backup First**: Always backup your database before running migrations
- **Test in Staging**: Apply migrations to a staging environment first
- **No Data Loss**: This migration only updates metadata and comments, no data is modified
- **Idempotent**: The migration can be run multiple times safely

## Migration Status

- [x] 001_rls_policies.sql - Applied (updated comments)
- [ ] 002_rebrand_to_origination.sql - Ready to apply

## Support

If you encounter any issues during migration:
1. Check the Supabase logs for error messages
2. Verify your database connection
3. Ensure you have sufficient permissions
4. Review the migration SQL for any syntax errors
