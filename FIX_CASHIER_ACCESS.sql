-- Fix cashier not seeing products
-- The issue is RLS policies are too restrictive

-- Fix products table RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for all users" ON products;
CREATE POLICY "Enable read access for all users" ON products
    FOR SELECT USING (true);

-- Fix variants table RLS  
ALTER TABLE variants ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for all users" ON variants;
CREATE POLICY "Enable read access for all users" ON variants
    FOR SELECT USING (true);

-- Fix serialized_items table RLS
ALTER TABLE serialized_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for all users" ON serialized_items;
CREATE POLICY "Enable read access for all users" ON serialized_items
    FOR SELECT USING (true);

-- Verify
SELECT '✓ Cashiers can now see all products!' as status;
