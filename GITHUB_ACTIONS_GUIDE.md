# GitHub Actions APK Build Guide

## 📋 Overview

This guide explains how to use GitHub Actions to automatically build APK files for the Compass app.

## 🚀 Quick Start

### 1. Push Code to GitHub

```bash
# Initialize git (if not already done)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: Compass app with recordings feature"

# Add remote repository
git remote add origin https://github.com/YOUR_USERNAME/compass.git

# Push to main branch
git push -u origin main
```

### 2. GitHub Actions Workflow

The workflow file is located at: `.github/workflows/build-apk.yml`

It automatically triggers on:
- **Push to main or develop branches**
- **Pull requests to main or develop**
- **Manual trigger** (via Actions tab)

### 3. Download APK

1. Go to your GitHub repository
2. Click on **Actions** tab
3. Click on the latest workflow run
4. Scroll down to **Artifacts**
5. Download:
   - `compass-debug.apk` (for testing)
   - `compass-release.apk` (for distribution)

## 🔧 Workflow Configuration

### Triggers

```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
  workflow_dispatch:  # Manual trigger
```

### Build Steps

1. **Checkout code** - Pulls your repository
2. **Setup Java** - Installs Java 17 (required for Android build)
3. **Setup Flutter** - Installs Flutter 3.24.5
4. **Get dependencies** - Runs `flutter pub get`
5. **Run analyzer** - Checks for code issues
6. **Build Debug APK** - Creates debug version
7. **Build Release APK** - Creates release version
8. **Upload artifacts** - Makes APKs downloadable

## 📦 APK Types

### Debug APK
- **File**: `compass-debug.apk`
- **Use**: Testing on emulator/device
- **Size**: Larger (includes debug symbols)
- **Performance**: Slower
- **Signing**: Debug key

### Release APK
- **File**: `compass-release.apk`
- **Use**: Distribution/production
- **Size**: Smaller (optimized)
- **Performance**: Faster
- **Signing**: Debug key (for now)

## 🎯 Manual Workflow Trigger

### Via GitHub UI

1. Go to **Actions** tab
2. Click **Build APK** workflow
3. Click **Run workflow**
4. Select branch (main/develop)
5. Click **Run workflow**
6. Wait for build to complete
7. Download artifacts

### Via GitHub CLI

```bash
# Install GitHub CLI
# https://cli.github.com/

# Trigger workflow
gh workflow run build-apk.yml --ref main

# Check status
gh run list --workflow=build-apk.yml

# Download artifacts
gh run download <RUN_ID> -n compass-release.apk
```

## 🏷️ Release Builds

### Create a Release

```bash
# Create a tag
git tag v1.0.0

# Push tag to GitHub
git push origin v1.0.0
```

The workflow will:
1. Build the APK
2. Create a GitHub Release
3. Upload APK as release asset

### Download Release APK

1. Go to **Releases** section
2. Click on the release
3. Download `compass-v1.0.0-release.apk`

## 🔐 Signing Configuration

### Current Setup
- Uses **debug signing key** (for development)
- Located at: `~/.android/debug.keystore`

### For Production Release

Create a signing configuration:

1. **Generate keystore** (one-time)
   ```bash
   keytool -genkey -v -keystore my-release-key.keystore \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias my-key-alias
   ```

2. **Add to GitHub Secrets**
   - Go to Settings → Secrets and variables → Actions
   - Add `KEYSTORE_FILE` (base64 encoded keystore)
   - Add `KEYSTORE_PASSWORD`
   - Add `KEY_ALIAS`
   - Add `KEY_PASSWORD`

3. **Update workflow** to use secrets:
   ```yaml
   - name: Build Release APK
     env:
       KEYSTORE_FILE: ${{ secrets.KEYSTORE_FILE }}
       KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
       KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
       KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
     run: |
       echo $KEYSTORE_FILE | base64 -d > keystore.jks
       flutter build apk --release \
         --keystore=keystore.jks \
         --keystore-password=$KEYSTORE_PASSWORD \
         --key-alias=$KEY_ALIAS \
         --key-password=$KEY_PASSWORD
   ```

## 📊 Build Status

### Check Build Status

1. Go to **Actions** tab
2. See workflow runs with status:
   - ✅ **Success** - APK built successfully
   - ❌ **Failed** - Build failed (check logs)
   - ⏳ **In Progress** - Build running

### View Build Logs

1. Click on workflow run
2. Click on **Build** job
3. Expand steps to see logs
4. Check for errors

## 🐛 Troubleshooting

### Build Fails

**Check logs**:
1. Go to Actions tab
2. Click failed workflow
3. Click "Build" job
4. Expand failed step
5. Read error message

**Common issues**:

| Error | Solution |
|-------|----------|
| `Gradle build timeout` | Increase timeout in workflow |
| `Java version mismatch` | Ensure Java 17 is used |
| `Flutter not found` | Check Flutter installation step |
| `Dependency resolution failed` | Run `flutter pub get` locally |
| `Android SDK not found` | Workflow handles this automatically |

### APK Not Downloading

1. Check if build succeeded (green checkmark)
2. Scroll to **Artifacts** section
3. If no artifacts, build failed - check logs
4. Try manual trigger of workflow

### APK Installation Fails

**On device**:
```bash
# Check if APK is compatible
adb install compass-release.apk

# If fails, try debug APK
adb install compass-debug.apk

# Check device logs
adb logcat
```

## 📈 Performance Tips

### Faster Builds

1. **Use split APKs** (by architecture):
   ```yaml
   - name: Build Release APK (Split)
     run: flutter build apk --release --split-per-abi
   ```

2. **Cache dependencies**:
   ```yaml
   - name: Cache Flutter dependencies
     uses: actions/cache@v3
     with:
       path: ~/.pub-cache
       key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
   ```

3. **Parallel builds**:
   ```yaml
   - name: Build Debug & Release in Parallel
     run: |
       flutter build apk --debug &
       flutter build apk --release &
       wait
   ```

## 🔄 Continuous Integration

### Auto-build on Push

The workflow automatically builds on every push to main/develop:

```yaml
on:
  push:
    branches: [ main, develop ]
```

### Auto-build on Pull Request

Builds are created for pull requests to verify changes:

```yaml
on:
  pull_request:
    branches: [ main, develop ]
```

### Scheduled Builds

Add nightly builds:

```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM UTC daily
```

## 📝 Workflow File Location

`.github/workflows/build-apk.yml`

### Key Sections

```yaml
name: Build APK                    # Workflow name
on:                                # Triggers
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
  workflow_dispatch:

jobs:
  build:                           # Job name
    runs-on: ubuntu-latest         # Runner
    steps:                         # Build steps
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
      - uses: subosito/flutter-action@v2
      # ... more steps
```

## 🎓 Advanced Usage

### Matrix Builds (Multiple Configurations)

```yaml
strategy:
  matrix:
    flutter-version: ['3.24.5', '3.25.0']
    
steps:
  - uses: subosito/flutter-action@v2
    with:
      flutter-version: ${{ matrix.flutter-version }}
```

### Conditional Steps

```yaml
- name: Build Release APK
  if: github.event_name == 'push' && github.ref == 'refs/heads/main'
  run: flutter build apk --release
```

### Notifications

```yaml
- name: Notify on Failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Build failed!'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter GitHub Actions](https://github.com/subosito/flutter-action)
- [Android Build Documentation](https://developer.android.com/build)
- [Gradle Documentation](https://gradle.org/docs/)

## ✅ Checklist

- [ ] Code pushed to GitHub
- [ ] `.github/workflows/build-apk.yml` exists
- [ ] Workflow triggers on push
- [ ] Build completes successfully
- [ ] APK artifacts are downloadable
- [ ] APK installs on device
- [ ] App runs without errors

---

**Last Updated**: May 6, 2026
**Version**: 1.0.0
