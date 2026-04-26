-- =============================================================================
-- QUICK SETUP: Run this ENTIRE file in Supabase SQL Editor
-- This will create all tables, policies, and your admin profile
-- =============================================================================

-- Step 1: Create all tables
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  role TEXT DEFAULT 'cashier' CHECK (role IN ('admin', 'manager', 'cashier', 'storekeeper')),
  business_id UUID,
  plan TEXT DEFAULT 'free' CHECK (plan IN ('free', 'pro', 'enterprise')),
  trial_ends_at TIMESTAMPTZ,
  onboarding_completed BOOLEAN DEFAULT false,
  referral_code TEXT UNIQUE,
  referred_by TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS brands (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  brand_id TEXT REFERENCES brands(id),
  cat_id TEXT REFERENCES categories(id),
  description TEXT,
  business_id UUID,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS variants (
  id TEXT PRIMARY KEY,
  product_id TEXT REFERENCES products(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  sku TEXT,
  barcode TEXT,
  cost NUMERIC(10,2) DEFAULT 0,
  price NUMERIC(10,2) NOT NULL,
  qty INTEGER DEFAULT 0,
  reorder_level INTEGER DEFAULT 5,
  business_id UUID,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS serialized_items (
  id TEXT PRIMARY KEY,
  variant_id TEXT REFERENCES variants(id) ON DELETE CASCADE,
  serial TEXT NOT NULL UNIQUE,
  status TEXT DEFAULT 'available' CHECK (status IN ('available', 'sold', 'returned')),
  date_added TIMESTAMPTZ DEFAULT now(),
  sold_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS sales (
  id TEXT PRIMARY KEY,
  receipt_no TEXT NOT NULL,
  date TIMESTAMPTZ DEFAULT now(),
  total NUMERIC(10,2) NOT NULL,
  payment_method TEXT DEFAULT 'cash' CHECK (payment_method IN ('cash', 'card', 'mobile')),
  cashier_id UUID REFERENCES auth.users(id),
  customer_name TEXT,
  customer_phone TEXT,
  business_id UUID,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS sale_items (
  id TEXT PRIMARY KEY,
  sale_id TEXT REFERENCES sales(id) ON DELETE CASCADE,
  variant_id TEXT REFERENCES variants(id),
  product_name TEXT NOT NULL,
  variant_name TEXT,
  qty INTEGER NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  subtotal NUMERIC(10,2) NOT NULL,
  serialized BOOLEAN DEFAULT false,
  serial_id TEXT REFERENCES serialized_items(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS suppliers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  contact TEXT,
  phone TEXT,
  email TEXT,
  address TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS stock_moves (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL CHECK (type IN ('sale', 'restock', 'adjustment', 'return')),
  variant_id TEXT REFERENCES variants(id),
  qty INTEGER NOT NULL,
  ref TEXT,
  date TIMESTAMPTZ DEFAULT now(),
  user_id UUID REFERENCES auth.users(id),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS customers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  address TEXT,
  total_purchases NUMERIC(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  action TEXT NOT NULL,
  table_name TEXT NOT NULL,
  record_id TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Step 2: Create indexes
-- -----------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_products_brand ON products(brand_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(cat_id);
CREATE INDEX IF NOT EXISTS idx_variants_product ON variants(product_id);
CREATE INDEX IF NOT EXISTS idx_variants_barcode ON variants(barcode);
CREATE INDEX IF NOT EXISTS idx_serialized_variant ON serialized_items(variant_id);
CREATE INDEX IF NOT EXISTS idx_serialized_serial ON serialized_items(serial);
CREATE INDEX IF NOT EXISTS idx_sales_date ON sales(date);
CREATE INDEX IF NOT EXISTS idx_sales_cashier ON sales(cashier_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_sale ON sale_items(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_variant ON sale_items(variant_id);
CREATE INDEX IF NOT EXISTS idx_stock_moves_variant ON stock_moves(variant_id);
CREATE INDEX IF NOT EXISTS idx_stock_moves_date ON stock_moves(date);

-- Step 3: Insert default data
-- -----------------------------------------------------------------------------

INSERT INTO categories (id, name, icon) VALUES
  ('grocery', 'Grocery', 'fa-shopping-basket'),
  ('electronics', 'Electronics', 'fa-laptop'),
  ('beverages', 'Beverages', 'fa-glass-water'),
  ('snacks', 'Snacks', 'fa-cookie-bite'),
  ('household', 'Household', 'fa-house'),
  ('personal-care', 'Personal Care', 'fa-spray-can-sparkles'),
  ('frozen', 'Frozen Foods', 'fa-snowflake'),
  ('bakery', 'Bakery', 'fa-bread-slice'),
  ('dairy', 'Dairy', 'fa-cheese')
ON CONFLICT (id) DO NOTHING;

INSERT INTO brands (id, name) VALUES
  ('generic', 'Generic'),
  ('local', 'Local Brand'),
  ('imported', 'Imported')
ON CONFLICT (id) DO NOTHING;

-- Step 4: Create helper functions
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_variants_updated_at BEFORE UPDATE ON variants
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_suppliers_updated_at BEFORE UPDATE ON suppliers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE FUNCTION get_my_role()
RETURNS TEXT LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT role FROM profiles WHERE id = auth.uid()
$$;

CREATE OR REPLACE FUNCTION get_my_business_id()
RETURNS UUID LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT business_id FROM profiles WHERE id = auth.uid()
$$;

-- Step 5: Enable RLS
-- -----------------------------------------------------------------------------

ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Step 6: Create RLS policies
-- -----------------------------------------------------------------------------

-- Profiles policies
DROP POLICY IF EXISTS "profiles_select" ON profiles;
CREATE POLICY "profiles_select" ON profiles FOR SELECT TO authenticated
  USING (id = auth.uid() OR (get_my_role() = 'admin' AND business_id = get_my_business_id()));

DROP POLICY IF EXISTS "profiles_insert" ON profiles;
CREATE POLICY "profiles_insert" ON profiles FOR INSERT TO authenticated
  WITH CHECK (id = auth.uid());

DROP POLICY IF EXISTS "profiles_update" ON profiles;
CREATE POLICY "profiles_update" ON profiles FOR UPDATE TO authenticated
  USING (id = auth.uid() OR get_my_role() = 'admin')
  WITH CHECK (id = auth.uid() OR get_my_role() = 'admin');

-- Sales policies
DROP POLICY IF EXISTS "sales_select" ON sales;
CREATE POLICY "sales_select" ON sales FOR SELECT TO authenticated
  USING (business_id = get_my_business_id());

DROP POLICY IF EXISTS "sales_insert" ON sales;
CREATE POLICY "sales_insert" ON sales FOR INSERT TO authenticated
  WITH CHECK (business_id = get_my_business_id() AND get_my_role() IN ('admin', 'cashier'));

DROP POLICY IF EXISTS "sales_update" ON sales;
CREATE POLICY "sales_update" ON sales FOR UPDATE TO authenticated
  USING (business_id = get_my_business_id() AND get_my_role() = 'admin')
  WITH CHECK (business_id = get_my_business_id() AND get_my_role() = 'admin');

DROP POLICY IF EXISTS "sales_delete" ON sales;
CREATE POLICY "sales_delete" ON sales FOR DELETE TO authenticated
  USING (business_id = get_my_business_id() AND get_my_role() = 'admin');

-- Products policies
DROP POLICY IF EXISTS "products_select" ON products;
CREATE POLICY "products_select" ON products FOR SELECT TO authenticated
  USING (business_id = get_my_business_id());

DROP POLICY IF EXISTS "products_insert" ON products;
CREATE POLICY "products_insert" ON products FOR INSERT TO authenticated
  WITH CHECK (business_id = get_my_business_id() AND get_my_role() IN ('admin', 'manager'));

DROP POLICY IF EXISTS "products_update" ON products;
CREATE POLICY "products_update" ON products FOR UPDATE TO authenticated
  USING (business_id = get_my_business_id() AND get_my_role() IN ('admin', 'manager'))
  WITH CHECK (business_id = get_my_business_id() AND get_my_role() IN ('admin', 'manager'));

DROP POLICY IF EXISTS "products_delete" ON products;
CREATE POLICY "products_delete" ON products FOR DELETE TO authenticated
  USING (business_id = get_my_business_id() AND get_my_role() = 'admin');

-- Variants policies
DROP POLICY IF EXISTS "variants_select" ON variants;
CREATE POLICY "variants_select" ON variants FOR SELECT TO authenticated
  USING (business_id = get_my_business_id());

DROP POLICY IF EXISTS "variants_insert" ON variants;
CREATE POLICY "variants_insert" ON variants FOR INSERT TO authenticated
  WITH CHECK (business_id = get_my_business_id() AND get_my_role() IN ('admin', 'manager'));

DROP POLICY IF EXISTS "variants_update" ON variants;
CREATE POLICY "variants_update" ON variants FOR UPDATE TO authenticated
  USING (business_id = get_my_business_id() AND get_my_role() IN ('admin', 'manager'))
  WITH CHECK (business_id = get_my_business_id() AND get_my_role() IN ('admin', 'manager'));

-- Audit logs policies
DROP POLICY IF EXISTS "audit_logs_select" ON audit_logs;
CREATE POLICY "audit_logs_select" ON audit_logs FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR get_my_role() = 'admin');

DROP POLICY IF EXISTS "audit_logs_insert" ON audit_logs;
CREATE POLICY "audit_logs_insert" ON audit_logs FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Step 7: Create your admin profile
-- IMPORTANT: Replace the UUID below with YOUR actual user ID
-- -----------------------------------------------------------------------------

-- First, let's see your user ID:
-- SELECT id, email FROM auth.users;

-- Then uncomment and run this (replace YOUR_USER_ID):
INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
VALUES (
  '974f1df3-b127-4cfd-924f-1a156af9a9a8',  -- YOUR USER ID FROM THE ERROR MESSAGE
  'Admin User',
  'admin',
  gen_random_uuid(),
  'free',
  true
)
ON CONFLICT (id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  role = EXCLUDED.role,
  onboarding_completed = EXCLUDED.onboarding_completed;

-- =============================================================================
-- DONE! Refresh your app and it should work now.
-- =============================================================================
