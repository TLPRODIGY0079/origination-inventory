-- =============================================================================
-- Migration: 000_create_schema.sql
-- Description: Create base schema for Origination-Inventory
-- Apply this FIRST in the Supabase SQL editor
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Create profiles table (extends auth.users)
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

-- -----------------------------------------------------------------------------
-- 2. Create categories table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- -----------------------------------------------------------------------------
-- 3. Create brands table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS brands (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- -----------------------------------------------------------------------------
-- 4. Create products table
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- 5. Create variants table
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- 6. Create serialized_items table (for IMEI/Serial tracking)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS serialized_items (
  id TEXT PRIMARY KEY,
  variant_id TEXT REFERENCES variants(id) ON DELETE CASCADE,
  serial TEXT NOT NULL UNIQUE,
  status TEXT DEFAULT 'available' CHECK (status IN ('available', 'sold', 'returned')),
  date_added TIMESTAMPTZ DEFAULT now(),
  sold_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- -----------------------------------------------------------------------------
-- 7. Create sales table
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- 8. Create sale_items table
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- 9. Create suppliers table
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- 10. Create stock_moves table (inventory tracking)
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- 11. Create customers table
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- 12. Create indexes for performance
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

-- -----------------------------------------------------------------------------
-- 13. Insert default categories
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

-- -----------------------------------------------------------------------------
-- 14. Insert default brands
-- -----------------------------------------------------------------------------
INSERT INTO brands (id, name) VALUES
  ('generic', 'Generic'),
  ('local', 'Local Brand'),
  ('imported', 'Imported')
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 15. Create trigger to update updated_at timestamp
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

-- =============================================================================
-- End of schema creation
-- =============================================================================
