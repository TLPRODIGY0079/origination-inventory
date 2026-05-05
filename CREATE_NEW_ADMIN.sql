-- =============================================================================
-- Create New Admin User
-- Run this in Supabase SQL Editor to create a new admin account
-- =============================================================================

-- STEP 1: Create the user in Supabase Auth Dashboard first
-- =============================================================================
-- 1. Go to Supabase Dashboard → Authentication → Users
-- 2. Click "Add user" → "Create new user"
-- 3. Enter email and password
-- 4. Click "Create user"
-- 5. Copy the user's UUID (you'll need it below)

-- STEP 2: Create the profile for the new admin
-- =============================================================================
-- Replace 'USER-UUID-HERE' with the actual UUID from Step 1
-- Replace 'Admin Name' with the actual name
-- Replace 'BUSINESS-UUID-HERE' with your business UUID (get it from existing admin)

-- First, get the business_id from an existing admin:
SELECT business_id FROM profiles WHERE role = 'admin' LIMIT 1;

-- Copy the business_id from the result above, then run this:
INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
VALUES (
  'USER-UUID-HERE',           -- Replace with the user UUID from Step 1
  'Admin Name',                -- Replace with the admin's full name
  'admin',                     -- Role
  'BUSINESS-UUID-HERE',        -- Replace with business_id from query above
  'free',                      -- Plan (can be 'free', 'pro', or 'enterprise')
  true                         -- Onboarding completed
);

-- =============================================================================
-- ALTERNATIVE: If you don't have the UUID yet, use this automated approach
-- =============================================================================

-- This will create a profile for ANY user that doesn't have one yet
-- It will use the business_id from the first admin it finds

INSERT INTO profiles (id, full_name, role, business_id, plan, onboarding_completed)
SELECT 
  au.id,
  COALESCE(au.raw_user_meta_data->>'full_name', split_part(au.email, '@', 1)) as full_name,
  'admin' as role,
  (SELECT business_id FROM profiles WHERE role = 'admin' LIMIT 1) as business_id,
  'free' as plan,
  true as onboarding_completed
FROM auth.users au
LEFT JOIN profiles p ON p.id = au.id
WHERE p.id IS NULL;

-- =============================================================================
-- STEP 3: Verify the new admin was created
-- =============================================================================

SELECT 
  p.id,
  p.full_name,
  p.role,
  p.business_id,
  au.email
FROM profiles p
JOIN auth.users au ON au.id = p.id
WHERE p.role = 'admin'
ORDER BY p.created_at DESC;

-- =============================================================================
-- STEP 4: Update existing admin if needed
-- =============================================================================

-- If you need to update an existing user to admin role:
-- Replace 'user@example.com' with the actual email

UPDATE profiles
SET 
  role = 'admin',
  full_name = COALESCE(full_name, 'Admin User'),
  business_id = (SELECT business_id FROM profiles WHERE role = 'admin' LIMIT 1)
WHERE id = (SELECT id FROM auth.users WHERE email = 'user@example.com');

-- =============================================================================
-- TROUBLESHOOTING
-- =============================================================================

-- Check if user exists in auth.users but not in profiles:
SELECT 
  au.id,
  au.email,
  au.created_at,
  CASE WHEN p.id IS NULL THEN 'MISSING PROFILE' ELSE 'Has Profile' END as status
FROM auth.users au
LEFT JOIN profiles p ON p.id = au.id
ORDER BY au.created_at DESC;

-- If you see "MISSING PROFILE", run the automated INSERT above

-- =============================================================================
-- NOTES:
-- - All admins in the same business must have the same business_id
-- - If business_id is NULL, the admin won't see any data
-- - The full_name field is required for the sidebar to work properly
-- =============================================================================
