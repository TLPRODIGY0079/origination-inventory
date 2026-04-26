# Origination-Inventory Deployment Guide

## Overview
This guide walks you through pushing your rebranded application to a new GitHub repository and deploying it to Netlify.

---

## Part 1: Push to New GitHub Repository

### Step 1: Create a New GitHub Repository

1. Go to [GitHub](https://github.com)
2. Click the **"+"** icon in the top right corner
3. Select **"New repository"**
4. Fill in the details:
   - **Repository name**: `origination-inventory`
   - **Description**: "Point of Sale and Inventory Management System for Origination stores"
   - **Visibility**: Choose Public or Private
   - **DO NOT** initialize with README, .gitignore, or license (we already have these)
5. Click **"Create repository"**

### Step 2: Prepare Your Local Repository

Open your terminal in the project directory and run:

```bash
# Check current git status
git status

# Add all rebranded files
git add .

# Commit the rebrand changes
git commit -m "Complete rebrand to Origination-Inventory with new color scheme and logo"

# Check current remote (if any)
git remote -v
```

### Step 3: Change Remote to New Repository

```bash
# Remove old remote (if exists)
git remote remove origin

# Add new remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/origination-inventory.git

# Verify new remote
git remote -v
```

### Step 4: Push to New Repository

```bash
# Push to main branch (or master, depending on your default branch)
git push -u origin main

# If you get an error about branch name, try:
git branch -M main
git push -u origin main
```

### Step 5: Verify on GitHub

1. Go to your new repository URL: `https://github.com/YOUR_USERNAME/origination-inventory`
2. Verify all files are present
3. Check that the README displays correctly

---

## Part 2: Deploy to Netlify

### Option A: Deploy via Netlify Dashboard (Recommended)

#### Step 1: Sign Up / Log In to Netlify

1. Go to [Netlify](https://www.netlify.com)
2. Click **"Sign up"** or **"Log in"**
3. Choose **"Sign up with GitHub"** for easier integration

#### Step 2: Create New Site

1. Click **"Add new site"** button
2. Select **"Import an existing project"**
3. Choose **"Deploy with GitHub"**
4. Authorize Netlify to access your GitHub account (if first time)

#### Step 3: Select Repository

1. Find and click on **"origination-inventory"** repository
2. If you don't see it, click **"Configure Netlify on GitHub"** to grant access

#### Step 4: Configure Build Settings

Since this is a static HTML/CSS/JS application, use these settings:

- **Branch to deploy**: `main` (or `master`)
- **Build command**: Leave empty (no build needed)
- **Publish directory**: `.` (root directory)
- **Environment variables**: Add if needed (see below)

#### Step 5: Add Environment Variables (Optional)

If your app needs environment variables:

1. Click **"Show advanced"**
2. Click **"New variable"**
3. Add your Supabase credentials:
   - `SUPABASE_URL`: Your Supabase project URL
   - `SUPABASE_ANON_KEY`: Your Supabase anonymous key

#### Step 6: Deploy Site

1. Click **"Deploy site"**
2. Wait for deployment to complete (usually 1-2 minutes)
3. You'll see a random URL like: `https://random-name-123456.netlify.app`

#### Step 7: Configure Custom Domain (Optional)

1. Go to **"Site settings"** > **"Domain management"**
2. Click **"Add custom domain"**
3. Enter your domain: `origination-inventory.com`
4. Follow DNS configuration instructions
5. Netlify will automatically provision SSL certificate

#### Step 8: Configure Site Settings

1. **Site name**: Change from random name to something memorable
   - Go to **"Site settings"** > **"General"** > **"Site details"**
   - Click **"Change site name"**
   - Enter: `origination-inventory`
   - Your URL becomes: `https://origination-inventory.netlify.app`

2. **Build settings**: Verify settings are correct
   - Go to **"Site settings"** > **"Build & deploy"**
   - Ensure publish directory is `.`

3. **Deploy notifications**: Set up notifications (optional)
   - Go to **"Site settings"** > **"Build & deploy"** > **"Deploy notifications"**
   - Add email or Slack notifications

---

### Option B: Deploy via Netlify CLI

#### Step 1: Install Netlify CLI

```bash
npm install -g netlify-cli
```

#### Step 2: Login to Netlify

```bash
netlify login
```

This will open a browser window to authorize the CLI.

#### Step 3: Initialize Netlify Site

```bash
# Navigate to your project directory
cd /path/to/origination-inventory

# Initialize Netlify
netlify init
```

Follow the prompts:
- **Create & configure a new site**: Yes
- **Team**: Select your team
- **Site name**: `origination-inventory`
- **Build command**: Leave empty
- **Directory to deploy**: `.`

#### Step 4: Deploy

```bash
# Deploy to production
netlify deploy --prod
```

---

## Part 3: Configure Netlify for Your App

### Create netlify.toml Configuration

Create a `netlify.toml` file in your project root:

```toml
[build]
  publish = "."
  command = ""

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-XSS-Protection = "1; mode=block"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "strict-origin-when-cross-origin"

[[headers]]
  for = "/assets/*"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

[[headers]]
  for = "/*.js"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

[[headers]]
  for = "/*.css"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"
```

### Update Your Repository

```bash
# Add netlify.toml
git add netlify.toml
git commit -m "Add Netlify configuration"
git push origin main
```

Netlify will automatically redeploy with the new configuration.

---

## Part 4: Post-Deployment Configuration

### 1. Update Supabase CORS Settings

1. Go to your Supabase project dashboard
2. Navigate to **Settings** > **API**
3. Add your Netlify URL to allowed origins:
   - `https://origination-inventory.netlify.app`
   - Your custom domain (if configured)

### 2. Update Application URLs

Update any hardcoded URLs in your application:

**In main.js (Electron):**
```javascript
// Change from:
win.loadURL('https://tlpinventories.vercel.app');

// To:
win.loadURL('https://origination-inventory.netlify.app');
```

**Commit and push:**
```bash
git add main.js
git commit -m "Update Electron app URL to Netlify deployment"
git push origin main
```

### 3. Configure Environment Variables

If you need to hide sensitive data:

1. Go to **Site settings** > **Environment variables**
2. Add variables:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
3. Update your code to use environment variables (requires build step)

### 4. Set Up Continuous Deployment

Netlify automatically deploys when you push to GitHub:

1. Make changes locally
2. Commit and push to GitHub
3. Netlify automatically detects changes and redeploys
4. Check deploy status in Netlify dashboard

---

## Part 5: Testing Your Deployment

### 1. Basic Functionality Test

Visit your Netlify URL and test:
- [ ] Site loads correctly
- [ ] Logo displays properly
- [ ] Colors are correct (gold, white, black)
- [ ] Login page works
- [ ] Navigation functions
- [ ] Supabase connection works

### 2. Performance Test

1. Open Chrome DevTools
2. Go to Lighthouse tab
3. Run performance audit
4. Verify score > 90

### 3. Mobile Test

1. Open site on mobile device
2. Test responsive design
3. Verify touch interactions work
4. Check PWA installation

---

## Part 6: Troubleshooting

### Common Issues

#### Issue 1: 404 Errors on Page Refresh

**Solution**: Add redirects in `netlify.toml` (already included above)

#### Issue 2: Assets Not Loading

**Solution**: Check asset paths are relative, not absolute
```html
<!-- Good -->
<img src="assets/logos/origination-logo.png">

<!-- Bad -->
<img src="/assets/logos/origination-logo.png">
```

#### Issue 3: Supabase Connection Fails

**Solution**: 
1. Check CORS settings in Supabase
2. Verify Supabase URL and key are correct
3. Check browser console for errors

#### Issue 4: Service Worker Not Updating

**Solution**:
1. Clear browser cache
2. Update service worker version in `sw.js`
3. Force refresh (Ctrl+Shift+R)

---

## Part 7: Monitoring and Maintenance

### Netlify Analytics

1. Go to **Analytics** tab in Netlify dashboard
2. View traffic, performance, and errors
3. Set up alerts for downtime

### Deploy Logs

1. Go to **Deploys** tab
2. Click on any deploy to see logs
3. Check for errors or warnings

### Rollback Deployment

If something goes wrong:
1. Go to **Deploys** tab
2. Find previous successful deploy
3. Click **"Publish deploy"** to rollback

---

## Quick Reference Commands

```bash
# Push to new repository
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/origination-inventory.git
git push -u origin main

# Deploy with Netlify CLI
netlify login
netlify init
netlify deploy --prod

# Check deployment status
netlify status

# Open site in browser
netlify open:site

# View deploy logs
netlify logs
```

---

## Next Steps After Deployment

1. ✅ Test all functionality on live site
2. ✅ Configure custom domain (optional)
3. ✅ Set up SSL certificate (automatic with Netlify)
4. ✅ Configure analytics and monitoring
5. ✅ Update mobile app to point to new URL
6. ✅ Update desktop app to point to new URL
7. ✅ Share new URL with users
8. ✅ Monitor for issues

---

## Support Resources

- **Netlify Documentation**: https://docs.netlify.com
- **Netlify Community**: https://answers.netlify.com
- **GitHub Documentation**: https://docs.github.com
- **Supabase Documentation**: https://supabase.com/docs

---

**Deployment completed successfully!** 🚀

Your Origination-Inventory application is now live and accessible to users worldwide.
