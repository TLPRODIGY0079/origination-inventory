-- =============================================================================
-- Migration: 002_rebrand_to_origination.sql
-- Description: Rebrand from Marble POS to Origination-stores
-- Apply this in the Supabase SQL editor (or via supabase db push)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Update migration description comment
-- -----------------------------------------------------------------------------
COMMENT ON TABLE sales IS 'Sales transactions for Origination-stores';
COMMENT ON TABLE products IS 'Product catalog for Origination-stores';
COMMENT ON TABLE variants IS 'Product variants for Origination-stores';
COMMENT ON TABLE profiles IS 'User profiles for Origination-stores';
COMMENT ON TABLE audit_logs IS 'Audit logs for Origination-stores';

-- -----------------------------------------------------------------------------
-- 2. Update any stored procedures or functions with branding references
-- -----------------------------------------------------------------------------

-- Update the RLS policies description (metadata only, policies remain functional)
COMMENT ON POLICY "sales_select" ON sales IS 'Origination-stores: Users can view sales from their business';
COMMENT ON POLICY "sales_insert" ON sales IS 'Origination-stores: Admin/cashier can create sales';
COMMENT ON POLICY "sales_update" ON sales IS 'Origination-stores: Admin can update sales';
COMMENT ON POLICY "sales_delete" ON sales IS 'Origination-stores: Admin can delete sales';

COMMENT ON POLICY "products_select" ON products IS 'Origination-stores: Users can view products from their business';
COMMENT ON POLICY "products_insert" ON products IS 'Origination-stores: Admin/manager can create products';
COMMENT ON POLICY "products_update" ON products IS 'Origination-stores: Admin/manager can update products';
COMMENT ON POLICY "products_delete" ON products IS 'Origination-stores: Admin can delete products';

COMMENT ON POLICY "variants_select" ON variants IS 'Origination-stores: Users can view variants from their business';
COMMENT ON POLICY "variants_insert" ON variants IS 'Origination-stores: Admin/manager can create variants';
COMMENT ON POLICY "variants_update" ON variants IS 'Origination-stores: Admin/manager can update variants';

COMMENT ON POLICY "profiles_select" ON profiles IS 'Origination-stores: Users can view their own profile or admin can view all';
COMMENT ON POLICY "audit_logs_select" ON audit_logs IS 'Origination-stores: Users can view their own logs or admin can view all';
COMMENT ON POLICY "audit_logs_insert" ON audit_logs IS 'Origination-stores: Users can insert their own audit logs';

-- -----------------------------------------------------------------------------
-- 3. Add application metadata table (optional)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS app_metadata (
  key TEXT PRIMARY KEY,
  value JSONB,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Insert branding metadata
INSERT INTO app_metadata (key, value) VALUES
  ('app_name', '"Origination-Inventory"'::jsonb),
  ('app_version', '"2.0.0"'::jsonb),
  ('rebrand_date', to_jsonb(now())),
  ('previous_name', '"Marble POS"'::jsonb)
ON CONFLICT (key) DO UPDATE SET
  value = EXCLUDED.value,
  updated_at = now();

-- -----------------------------------------------------------------------------
-- 4. Rollback procedure (if needed)
-- -----------------------------------------------------------------------------
-- To rollback this migration, run:
-- DELETE FROM app_metadata WHERE key IN ('app_name', 'app_version', 'rebrand_date', 'previous_name');
-- And update comments back to "Marble POS" references

-- =============================================================================
-- End of migration
-- =============================================================================
