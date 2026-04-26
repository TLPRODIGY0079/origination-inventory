# Netlify Deployment - Quick Start Guide

## 🚀 Deploy Origination-Inventory to Netlify in 5 Minutes

---

## Prerequisites

- ✅ GitHub account
- ✅ Netlify account (free tier is fine)
- ✅ Your rebranded code ready to push

---

## Step-by-Step Instructions

### 1️⃣ Create New GitHub Repository (2 minutes)

1. Go to https://github.com/new
2. Repository name: `origination-inventory`
3. Description: "Point of Sale and Inventory Management System"
4. Choose Public or Private
5. **DO NOT** check any initialization options
6. Click **"Create repository"**

### 2️⃣ Push Your Code to GitHub (1 minute)

Open your terminal in the project folder:

```bash
# Check git status
git status

# Add all files
git add .

# Commit changes
git commit -m "Initial commit: Origination-Inventory rebrand complete"

# Remove old remote (if exists)
git remote remove origin

# Add new remote (REPLACE YOUR_USERNAME!)
git remote add origin https://github.com/YOUR_USERNAME/origination-inventory.git

# Push to GitHub
git branch -M main
git push -u origin main
```

✅ **Verify**: Go to your GitHub repository and confirm files are there

### 3️⃣ Deploy to Netlify (2 minutes)

#### Option A: Via Netlify Dashboard (Easiest)

1. Go to https://app.netlify.com
2. Click **"Add new site"** → **"Import an existing project"**
3. Click **"Deploy with GitHub"**
4. Authorize Netlify (if first time)
5. Select **"origination-inventory"** repository
6. Configure settings:
   - **Branch**: `main`
   - **Build command**: Leave empty
   - **Publish directory**: `.` (just a dot)
7. Click **"Deploy site"**

#### Option B: Via Netlify CLI (For Advanced Users)

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login to Netlify
netlify login

# Initialize and deploy
netlify init

# Follow prompts:
# - Create new site
# - Site name: origination-inventory
# - Build command: (leave empty)
# - Publish directory: .

# Deploy to production
netlify deploy --prod
```

### 4️⃣ Configure Your Site (1 minute)

1. **Change site name** (optional but recommended):
   - Go to **Site settings** → **General** → **Site details**
   - Click **"Change site name"**
   - Enter: `origination-inventory`
   - Your URL becomes: `https://origination-inventory.netlify.app`

2. **Verify deployment**:
   - Click **"Open production deploy"**
   - Test that your site loads correctly
   - Check logo, colors, and functionality

---

## 🎉 You're Done!

Your site is now live at: `https://origination-inventory.netlify.app`

---

## Important Post-Deployment Steps

### Update Supabase CORS Settings

1. Go to your Supabase dashboard
2. Navigate to **Settings** → **API**
3. Scroll to **CORS Settings**
4. Add your Netlify URL:
   ```
   https://origination-inventory.netlify.app
   ```
5. Click **"Save"**

### Update Electron App URL

Edit `main.js`:

```javascript
// Change this line:
win.loadURL('https://tlpinventories.vercel.app');

// To this:
win.loadURL('https://origination-inventory.netlify.app');
```

Then commit and push:
```bash
git add main.js
git commit -m "Update Electron app URL to Netlify"
git push origin main
```

Netlify will automatically redeploy!

---

## Testing Your Deployment

### Quick Test Checklist

Visit your Netlify URL and verify:

- [ ] Site loads without errors
- [ ] Logo displays correctly (gold and black)
- [ ] Colors are correct (white, gold, black - no blue)
- [ ] Login page works
- [ ] Can navigate between pages
- [ ] Supabase connection works (try logging in)
- [ ] Mobile responsive design works
- [ ] Service worker activates (check DevTools)

### Performance Test

1. Open Chrome DevTools (F12)
2. Go to **Lighthouse** tab
3. Click **"Analyze page load"**
4. Verify performance score > 90

---

## Automatic Deployments

Netlify automatically deploys when you push to GitHub:

```bash
# Make changes to your code
# ... edit files ...

# Commit and push
git add .
git commit -m "Update feature X"
git push origin main

# Netlify automatically detects and deploys!
# Check status at: https://app.netlify.com
```

---

## Custom Domain Setup (Optional)

### If You Have a Domain

1. Go to **Site settings** → **Domain management**
2. Click **"Add custom domain"**
3. Enter your domain: `origination-inventory.com`
4. Follow DNS configuration instructions:

   **For most domain providers:**
   - Add CNAME record: `www` → `origination-inventory.netlify.app`
   - Add A record: `@` → Netlify's IP address

5. Wait for DNS propagation (5-30 minutes)
6. Netlify automatically provisions SSL certificate

---

## Troubleshooting

### Problem: Site shows 404 error

**Solution**: The `netlify.toml` file handles this. Make sure it's in your repository:

```bash
git add netlify.toml
git commit -m "Add Netlify configuration"
git push origin main
```

### Problem: Assets not loading

**Solution**: Check that asset paths are relative:
```html
<!-- ✅ Correct -->
<img src="assets/logos/origination-logo.png">

<!-- ❌ Wrong -->
<img src="/assets/logos/origination-logo.png">
```

### Problem: Supabase connection fails

**Solution**: 
1. Check CORS settings in Supabase (add Netlify URL)
2. Verify Supabase credentials in your code
3. Check browser console for specific errors

### Problem: Old version still showing

**Solution**:
1. Clear browser cache (Ctrl+Shift+Delete)
2. Hard refresh (Ctrl+Shift+R)
3. Check Netlify deploy status
4. Update service worker version in `sw.js`

---

## Monitoring Your Site

### View Deploy Status

1. Go to https://app.netlify.com
2. Click on your site
3. Go to **Deploys** tab
4. See all deployments and their status

### View Analytics (Optional)

1. Go to **Analytics** tab
2. View traffic, performance, and errors
3. Upgrade to paid plan for detailed analytics

### Set Up Notifications

1. Go to **Site settings** → **Build & deploy** → **Deploy notifications**
2. Add email or Slack notifications
3. Get notified when deploys succeed or fail

---

## Rollback if Needed

If something goes wrong:

1. Go to **Deploys** tab
2. Find the last working deploy
3. Click the three dots (⋮)
4. Click **"Publish deploy"**
5. Site instantly rolls back to that version

---

## Cost

**Netlify Free Tier Includes:**
- ✅ 100GB bandwidth/month
- ✅ 300 build minutes/month
- ✅ Automatic HTTPS
- ✅ Continuous deployment
- ✅ Custom domain support
- ✅ Form handling
- ✅ Serverless functions

This is more than enough for most small to medium applications!

---

## Next Steps

1. ✅ Share your live URL with users
2. ✅ Set up custom domain (optional)
3. ✅ Configure analytics
4. ✅ Set up deploy notifications
5. ✅ Update mobile and desktop apps with new URL
6. ✅ Run the database migration in Supabase
7. ✅ Complete testing checklist

---

## Quick Commands Reference

```bash
# Push to GitHub
git add .
git commit -m "Your message"
git push origin main

# Deploy with CLI
netlify deploy --prod

# Check status
netlify status

# Open site
netlify open:site

# View logs
netlify logs
```

---

## Support

- **Netlify Docs**: https://docs.netlify.com
- **Netlify Community**: https://answers.netlify.com
- **Status Page**: https://www.netlifystatus.com

---

## 🎊 Congratulations!

Your Origination-Inventory application is now live on Netlify!

**Your live URL**: `https://origination-inventory.netlify.app`

Share it with your users and start managing inventory! 🚀
