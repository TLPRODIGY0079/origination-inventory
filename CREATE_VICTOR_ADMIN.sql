-- =============================================================================
-- Create Victor as Admin - CORRECTED VERSION
-- =============================================================================

-- STEP 1: Create user in Supabase Auth Dashboard FIRST!
-- =============================================================================
-- You MUST do this in the Supabase Dashboard:
-- 1. Go to Authentication → Users
-- 2. Click "Add user" → "Create new user"
-- 3. Email: victormulenga@example.com (or whatever email Victor uses)
-- 4. Password: (set a password)
-- 5. Click "Create user"
-- 6. COPY THE USER UUID that is generated
-- 7. Come back here and use that UUID below

-- STEP 2: Find existing admin's business_id
-- =============================================================================
SELECT business_id FROM profiles WHERE role = 'admin' LIMIT 1;

-- Copy the business_id from the result above

-- STEP 3: Create Victor's profile
-- =============================================================================
-- Replace 'PASTE-VICTOR-UUID-HERE' with the UUID from Step 1
-- Replace 'PASTE-BUSINESS-ID-HERE' with the business_id from Step 2

INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
VALUES (
  'PASTE-VICTOR-UUID-HERE',           -- UUID from Supabase Auth Dashboard
  'Victor Mulenga',
  'admin',
  'PASTE-BUSINESS-ID-HERE',           -- business_id from query above
  'pro',
  true
)
ON CONFLICT (id) DO UPDATE SET
  full_name = 'Victor Mulenga',
  role = 'admin',
  business_id = EXCLUDED.business_id,
  plan = 'pro',
  onboarding_completed = true;

-- STEP 4: Add co-admin (kaelachanda2004@gmail.com)
-- =============================================================================
-- This will work if the user already exists in auth.users

INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
SELECT 
  au.id,
  COALESCE(au.raw_user_meta_data->>'full_name', 'Co-Admin') as full_name,
  'admin' as role,
  (SELECT business_id FROM profiles WHERE role = 'admin' LIMIT 1) as business_id,
  'pro' as plan,
  true as onboarding_completed
FROM auth.users au
WHERE au.email = 'kaelachanda2004@gmail.com'
ON CONFLICT (id) DO UPDATE SET
  role = 'admin',
  business_id = (SELECT business_id FROM profiles WHERE role = 'admin' LIMIT 1),
  plan = 'pro',
  onboarding_completed = true;

-- STEP 5: Verify both admins were created
-- =============================================================================
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

-- Expected result: You should see both Victor and kaelachanda2004@gmail.com

-- =============================================================================
-- TROUBLESHOOTING
-- =============================================================================

-- If kaelachanda2004@gmail.com doesn't exist in auth.users:
-- 1. Go to Supabase Dashboard → Authentication → Users
-- 2. Click "Add user" → "Create new user"
-- 3. Email: kaelachanda2004@gmail.com
-- 4. Password: (set a password)
-- 5. Click "Create user"
-- 6. Then run Step 4 again

-- Check if user exists in auth.users:
SELECT id, email, created_at FROM auth.users WHERE email IN ('kaelachanda2004@gmail.com');

-- If no result, the user doesn't exist - create it in the dashboard first!
