# 🚀 START HERE - Deploy Origination-Inventory

## Quick Start - Copy and Paste These Commands

### Step 1: Create GitHub Repository

1. Go to: https://github.com/new
2. Repository name: `origination-inventory`
3. Make it Public or Private (your choice)
4. **DO NOT** check any boxes
5. Click "Create repository"
6. **Copy your repository URL** (it will look like this):
   ```
   https://github.com/YOUR_USERNAME/origination-inventory.git
   ```

### Step 2: Push to New Repository

**Open your terminal in this folder and run these commands:**

```bash
# Check current status
git status

# Add all files
git add .

# Commit the rebrand
git commit -m "Complete Origination-Inventory rebrand with new branding"

# Remove old remote (if exists)
git remote remove origin

# Add YOUR new repository (REPLACE YOUR_USERNAME!)
git remote add origin https://github.com/YOUR_USERNAME/origination-inventory.git

# Push to GitHub
git branch -M main
git push -u origin main
```

**✅ Verify**: Go to your GitHub repository and see all files

### Step 3: Deploy to Netlify

**Choose ONE method:**

#### Method A: Netlify Dashboard (Easiest - Recommended)

1. Go to: https://app.netlify.com
2. Click "Add new site" → "Import an existing project"
3. Click "Deploy with GitHub"
4. Select "origination-inventory"
5. Settings:
   - Branch: `main`
   - Build command: (leave empty)
   - Publish directory: `.` (just a dot)
6. Click "Deploy site"
7. Wait 1-2 minutes
8. Click "Open production deploy"

#### Method B: Netlify CLI (For Advanced Users)

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Initialize
netlify init

# Deploy
netlify deploy --prod
```

### Step 4: Configure Site Name

1. In Netlify dashboard, click "Site settings"
2. Click "Change site name"
3. Enter: `origination-inventory`
4. Your URL becomes: `https://origination-inventory.netlify.app`

### Step 5: Update Supabase CORS

1. Go to: https://app.supabase.com
2. Select your project
3. Settings → API → CORS Settings
4. Add: `https://origination-inventory.netlify.app`
5. Click "Save"

### Step 6: Update Electron App (Optional)

Edit `main.js` line 13:

```javascript
// Change from:
win.loadURL('https://tlpinventories.vercel.app');

// To:
win.loadURL('https://origination-inventory.netlify.app');
```

Then push:
```bash
git add main.js
git commit -m "Update Electron URL to Netlify"
git push origin main
```

---

## 🎉 Done!

Your site is live at: `https://origination-inventory.netlify.app`

---

## 📚 Detailed Guides Available

- **NETLIFY_QUICKSTART.md** - 5-minute deployment guide
- **NETLIFY_VISUAL_GUIDE.md** - Step-by-step with screenshots
- **DEPLOYMENT_GUIDE.md** - Complete reference guide

---

## ✅ Quick Test

Visit your site and check:
- [ ] Logo displays (gold and black)
- [ ] Colors are correct (white, gold, black)
- [ ] Login page works
- [ ] Can navigate pages
- [ ] No console errors (F12)

---

## 🆘 Troubleshooting

**Site shows 404?**
- The `netlify.toml` file fixes this (already included)

**Assets not loading?**
- Check paths are relative: `assets/logos/...`

**Supabase not connecting?**
- Add Netlify URL to Supabase CORS settings

**Need more help?**
- Read NETLIFY_QUICKSTART.md
- Check Netlify docs: https://docs.netlify.com

---

## 🔄 Future Updates

Every time you push to GitHub, Netlify automatically deploys:

```bash
# Make changes
# ... edit files ...

# Push to GitHub
git add .
git commit -m "Your update message"
git push origin main

# Netlify deploys automatically!
```

---

## 📞 Support

- Netlify Docs: https://docs.netlify.com
- Netlify Community: https://answers.netlify.com
- GitHub Docs: https://docs.github.com

---

**Ready? Start with Step 1 above!** 🚀
