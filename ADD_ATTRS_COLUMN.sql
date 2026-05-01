-- Quick fix: Add attrs column to variants table
-- Run this in Supabase SQL Editor

ALTER TABLE variants 
ADD COLUMN IF NOT EXISTS attrs JSONB DEFAULT '{}'::jsonb;

-- Verify
SELECT 'attrs column added successfully!' as status;
