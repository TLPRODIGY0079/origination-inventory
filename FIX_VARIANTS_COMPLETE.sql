-- Complete fix for variants table
-- Run this in Supabase SQL Editor

-- Step 1: Make name column optional (allow NULL)
ALTER TABLE variants 
ALTER COLUMN name DROP NOT NULL;

-- Step 2: Set a default value for name
ALTER TABLE variants 
ALTER COLUMN name SET DEFAULT 'Variant';

-- Step 3: Fix RLS policies for variants
ALTER TABLE variants ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for all users" ON variants;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON variants;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON variants;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON variants;

CREATE POLICY "Enable read access for all users" ON variants
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON variants
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON variants
    FOR UPDATE USING (true);

CREATE POLICY "Enable delete for authenticated users" ON variants
    FOR DELETE USING (true);

-- Verify
SELECT '✓ Variants table fixed! RLS policies added and name column is now optional.' as status;
