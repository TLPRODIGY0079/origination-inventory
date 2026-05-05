-- =============================================================================
-- Create Admin Users - SIMPLE TEMPLATE
-- =============================================================================
-- 
-- BEFORE RUNNING THIS:
-- 1. Create users in Supabase Auth Dashboard (Authentication → Users → Add user)
-- 2. Copy their UUIDs
-- 3. Get your business_id (run the query below)
-- 4. Replace the placeholders in this file
-- 5. Run the INSERT statements
--
-- =============================================================================

-- STEP 1: Get your business_id
-- =============================================================================
-- Run this first and copy the result:

SELECT business_id FROM profiles WHERE role = 'admin' LIMIT 1;

-- Copy the business_id: _______________________________________


-- STEP 2: Create Victor's profile
-- =============================================================================
-- Replace these values:
--   - VICTOR_UUID: The UUID from Auth Dashboard for victormulenga@example.com
--   - YOUR_BUSINESS_ID: The business_id from Step 1

INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
VALUES (
  'VICTOR_UUID',              -- Replace with Victor's UUID from Auth Dashboard
  'Victor Mulenga',
  'admin',
  'YOUR_BUSINESS_ID',         -- Replace with business_id from Step 1
  'pro',
  true
)
ON CONFLICT (id) DO UPDATE SET
  full_name = 'Victor Mulenga',
  role = 'admin',
  business_id = EXCLUDED.business_id,
  plan = 'pro',
  onboarding_completed = true;


-- STEP 3: Create kaelachanda2004@gmail.com profile
-- =============================================================================
-- Replace these values:
--   - KAELA_UUID: The UUID from Auth Dashboard for kaelachanda2004@gmail.com
--   - YOUR_BUSINESS_ID: The same business_id from Step 1

INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
VALUES (
  'KAELA_UUID',               -- Replace with Kaela's UUID from Auth Dashboard
  'Co-Admin',
  'admin',
  'YOUR_BUSINESS_ID',         -- Replace with business_id from Step 1
  'pro',
  true
)
ON CONFLICT (id) DO UPDATE SET
  full_name = 'Co-Admin',
  role = 'admin',
  business_id = EXCLUDED.business_id,
  plan = 'pro',
  onboarding_completed = true;


-- STEP 4: Verify both admins were created
-- =============================================================================
-- Run this to confirm both admins exist:

SELECT 
  p.id,
  p.full_name,
  p.role,
  p.business_id,
  p.plan,
  au.email
FROM profiles p
JOIN auth.users au ON au.id = p.id
WHERE p.role = 'admin'
ORDER BY p.created_at;

-- You should see:
-- - Your original admin
-- - Victor Mulenga (victormulenga@example.com)
-- - Co-Admin (kaelachanda2004@gmail.com)
-- All with the SAME business_id


-- =============================================================================
-- EXAMPLE (for reference):
-- =============================================================================
-- If Victor's UUID is: 12345678-1234-1234-1234-123456789012
-- And business_id is: 87654321-4321-4321-4321-210987654321
-- 
-- Then the INSERT would look like:
--
-- INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
-- VALUES (
--   '12345678-1234-1234-1234-123456789012',
--   'Victor Mulenga',
--   'admin',
--   '87654321-4321-4321-4321-210987654321',
--   'pro',
--   true
-- );
-- =============================================================================
