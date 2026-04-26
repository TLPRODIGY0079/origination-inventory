# ✅ Correct Supabase Credentials Applied

## Your Supabase Project

**Project URL:** `https://ydogahzvieaunitxaoim.supabase.co`  
**Project ID:** `ydogahzvieaunitxaoim`  
**Anon Key:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (already configured)

---

## What I Updated

### Files Fixed:
- ✅ `supabase.js` - Already had correct credentials
- ✅ `index.html` - Updated to use correct project
- ✅ `login.html` - Already using shared client
- ✅ `signup.html` - Already using shared client

All files now use the **same Supabase project**: `ydogahzvieaunitxaoim`

---

## Next Steps

### 1. Create a User in YOUR Supabase Project

Go to: https://app.supabase.com/project/ydogahzvieaunitxaoim/auth/users

Click **"Add user"**:
- **Email:** `admin@origination-stores.com` (or your email)
- **Password:** `Admin123!` (or your password)
- **✓ Auto Confirm User** (CHECK THIS!)
- Click **"Create user"**

### 2. Update CORS Settings

Go to: https://app.supabase.com/project/ydogahzvieaunitxaoim/settings/api

Scroll to **CORS Settings** and add your deployment URL:
```
https://origination-inventory.vercel.app
```
(or your Netlify URL)

Click **"Save"**

### 3. Push Changes

```bash
git add supabase.js index.html
git commit -m "Fix: Use correct Supabase project credentials"
git push origin main
```

### 4. Test Login

1. Visit your deployed site
2. Enter the email/password you created in Step 1
3. Click "Sign In"
4. Should work now! ✅

---

## Troubleshooting

### Still Getting 401 Error?

**Check these:**

1. **User exists in correct project?**
   - Go to: https://app.supabase.com/project/ydogahzvieaunitxaoim/auth/users
   - Verify user is there
   - Check "Email Confirmed" column

2. **Correct password?**
   - Make sure you're using the exact password you set
   - Passwords are case-sensitive

3. **Clear browser cache:**
   - Press `Ctrl+Shift+Delete`
   - Clear all cached data
   - Hard refresh: `Ctrl+Shift+R`

4. **Check browser console:**
   - Press `F12`
   - Look for specific error messages
   - Share them if you need help

### Getting "Invalid login credentials"?

This means:
- User doesn't exist, OR
- Password is wrong, OR
- User is not confirmed

**Solution:**
1. Go to Supabase dashboard
2. Check user exists
3. Check "Email Confirmed" has a date
4. Try resetting password or creating new user

---

## Quick Reference

### Your Supabase Dashboard Links

- **Project Home:** https://app.supabase.com/project/ydogahzvieaunitxaoim
- **Auth Users:** https://app.supabase.com/project/ydogahzvieaunitxaoim/auth/users
- **API Settings:** https://app.supabase.com/project/ydogahzvieaunitxaoim/settings/api
- **Database:** https://app.supabase.com/project/ydogahzvieaunitxaoim/editor

### Test User Template

When creating users, use this format:
- **Email:** `user@origination-stores.com`
- **Password:** At least 6 characters
- **✓ Auto Confirm User:** Always check this for testing
- **Role:** Set in user metadata if needed

---

## Summary

✅ All files now use project: `ydogahzvieaunitxaoim`  
✅ Credentials are correct  
✅ No more 401 errors (after creating user)  
✅ Ready to test login!

**Just create a user in Supabase and you're good to go!** 🚀
