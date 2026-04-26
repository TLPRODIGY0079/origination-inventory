-- =============================================================================
-- Migration: 003_add_missing_columns.sql
-- Description: Add missing columns to sales table for compatibility
-- Run this if you already created the database with the old schema
-- =============================================================================

-- Add missing columns to sales table
ALTER TABLE sales ADD COLUMN IF NOT EXISTS date_str TEXT;
ALTER TABLE sales ADD COLUMN IF NOT EXISTS total_amount NUMERIC(10,2);
ALTER TABLE sales ADD COLUMN IF NOT EXISTS cashier_name TEXT;
ALTER TABLE sales ADD COLUMN IF NOT EXISTS items INTEGER DEFAULT 0;
ALTER TABLE sales ADD COLUMN IF NOT EXISTS discount NUMERIC(10,2) DEFAULT 0;

-- Create a trigger to auto-populate date_str from date
CREATE OR REPLACE FUNCTION sync_date_str()
RETURNS TRIGGER AS $$
BEGIN
  NEW.date_str = (NEW.date AT TIME ZONE 'UTC')::DATE::TEXT;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sales_sync_date_str
  BEFORE INSERT OR UPDATE ON sales
  FOR EACH ROW
  EXECUTE FUNCTION sync_date_str();

-- Create a trigger to auto-populate total_amount from total
CREATE OR REPLACE FUNCTION sync_total_amount()
RETURNS TRIGGER AS $$
BEGIN
  NEW.total_amount = NEW.total;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sales_sync_total_amount
  BEFORE INSERT OR UPDATE ON sales
  FOR EACH ROW
  EXECUTE FUNCTION sync_total_amount();

-- Backfill existing data
UPDATE sales SET date_str = (date AT TIME ZONE 'UTC')::DATE::TEXT WHERE date_str IS NULL;
UPDATE sales SET total_amount = total WHERE total_amount IS NULL;

-- =============================================================================
-- End of migration
-- =============================================================================
