# Create Repository Manually on GitHub

## Step 1: Go to GitHub

Visit: https://github.com/new

## Step 2: Fill in Repository Details

- **Repository name**: `compass`
- **Description**: `Stealth secure chat app disguised as Compass utility`
- **Visibility**: Select **Public** (or Private if you prefer)
- **Initialize this repository with**: Leave **UNCHECKED** (we already have commits)

## Step 3: Click "Create repository"

## Step 4: After Repository is Created

You'll see a page with push instructions. Run this command in PowerShell:

```powershell
cd C:\Users\Nandu\Downloads\compass\my_app
git push -u origin main
```

When prompted for password, use your Personal Access Token (keep it secret!):
```
[Your GitHub Personal Access Token]
```

## That's it!

Your Compass app will be on GitHub! 🚀

---

**Repository URL**: https://github.com/saketh-nandu/compass
