-- =============================================================================
-- Create Trade-ins Table
-- =============================================================================
-- This creates a table to store trade-in transactions

-- Create trade_ins table
CREATE TABLE IF NOT EXISTS trade_ins (
  id TEXT PRIMARY KEY,
  receipt_no TEXT NOT NULL,
  date TIMESTAMPTZ DEFAULT now(),
  date_str TEXT,
  
  -- Trade-in device details
  trade_in_device_name TEXT NOT NULL,
  trade_in_imei TEXT,
  trade_in_value NUMERIC(10,2) NOT NULL,
  
  -- New device details
  new_variant_id TEXT REFERENCES variants(id),
  new_device_name TEXT NOT NULL,
  new_device_sku TEXT,
  new_device_price NUMERIC(10,2) NOT NULL,
  new_device_imei TEXT,
  
  -- Transaction details
  net_payment NUMERIC(10,2) NOT NULL,
  customer_name TEXT NOT NULL,
  
  -- Metadata
  cashier_id UUID REFERENCES auth.users(id),
  cashier_name TEXT,
  business_id UUID,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_trade_ins_date ON trade_ins(date);
CREATE INDEX IF NOT EXISTS idx_trade_ins_cashier ON trade_ins(cashier_id);
CREATE INDEX IF NOT EXISTS idx_trade_ins_variant ON trade_ins(new_variant_id);

-- Enable RLS
ALTER TABLE trade_ins ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "trade_ins_select" ON trade_ins;
DROP POLICY IF EXISTS "trade_ins_insert" ON trade_ins;
DROP POLICY IF EXISTS "trade_ins_update" ON trade_ins;
DROP POLICY IF EXISTS "trade_ins_delete" ON trade_ins;

-- Allow users to read trade-ins in their business
CREATE POLICY "trade_ins_select" ON trade_ins FOR SELECT
  TO authenticated
  USING (
    business_id = (SELECT business_id FROM profiles WHERE id = auth.uid())
  );

-- Allow users to insert trade-ins
CREATE POLICY "trade_ins_insert" ON trade_ins FOR INSERT
  TO authenticated
  WITH CHECK (
    business_id = (SELECT business_id FROM profiles WHERE id = auth.uid())
  );

-- Allow users to update their own trade-ins
CREATE POLICY "trade_ins_update" ON trade_ins FOR UPDATE
  TO authenticated
  USING (
    business_id = (SELECT business_id FROM profiles WHERE id = auth.uid())
  );

-- Only admins can delete trade-ins
CREATE POLICY "trade_ins_delete" ON trade_ins FOR DELETE
  TO authenticated
  USING (
    (SELECT role FROM profiles WHERE id = auth.uid()) = 'admin'
  );

-- =============================================================================
-- Verification
-- =============================================================================

-- Check that table was created
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'trade_ins'
ORDER BY ordinal_position;

-- Check that policies were created
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename = 'trade_ins'
ORDER BY policyname;

-- =============================================================================
-- DONE!
-- =============================================================================
-- After running this SQL:
-- 1. The trade_ins table will be created
-- 2. RLS policies will be applied
-- 3. Trade-in transactions can now be saved to the database
