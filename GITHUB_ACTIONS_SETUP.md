# GitHub Actions - APK Build Setup

## ✅ Workflow Configured

The GitHub Actions workflow is now set up to automatically build APKs on every push and pull request.

## 📋 Workflow Details

**File**: `.github/workflows/build-apk.yml`

**Triggers:**
- ✅ Push to `main` or `develop` branches
- ✅ Pull requests to `main` or `develop` branches
- ✅ Manual trigger via GitHub Actions UI

**Steps:**
1. Checkout code
2. Setup Java 17
3. Setup Flutter 3.27.0
4. Get dependencies
5. Clean build cache
6. Run Flutter analyzer
7. Build Debug APK
8. Build Release APK
9. Upload artifacts

## 🚀 How to Use

### Automatic Builds
Every time you push to `main` or `develop`, the workflow automatically:
1. Builds debug APK
2. Builds release APK
3. Uploads both as artifacts

### Manual Trigger
1. Go to: https://github.com/saketh-nandu/compass/actions
2. Click "Build APK" workflow
3. Click "Run workflow"
4. Select branch (main or develop)
5. Click "Run workflow"

### Download APKs
1. Go to: https://github.com/saketh-nandu/compass/actions
2. Click the latest workflow run
3. Scroll down to "Artifacts"
4. Download `compass-debug.apk` or `compass-release.apk`

## 📦 Build Outputs

**Debug APK:**
- Name: `compass-debug.apk`
- Location: `my_app/build/app/outputs/flutter-apk/app-debug.apk`
- Use for: Testing and development

**Release APK:**
- Name: `compass-release.apk`
- Location: `my_app/build/app/outputs/flutter-apk/app-release.apk`
- Use for: Production deployment

## 🔍 Monitoring Builds

### View Build Status
1. Go to: https://github.com/saketh-nandu/compass
2. Look for the green checkmark (✅) or red X (❌) next to commits
3. Click to see build details

### View Build Logs
1. Go to: https://github.com/saketh-nandu/compass/actions
2. Click the workflow run
3. Click "build" job
4. Expand steps to see logs

## ⚙️ Configuration

### Java Version
- Version: 17 (Temurin)
- Used for: Android build tools

### Flutter Version
- Version: 3.27.0
- Channel: stable

### Build Flags
- Debug: `flutter build apk --debug`
- Release: `flutter build apk --release`

## 🐛 Troubleshooting

### Build Fails
1. Check the build logs in GitHub Actions
2. Common issues:
   - Missing dependencies: Run `flutter pub get`
   - Analyzer errors: Run `flutter analyze`
   - Java version mismatch: Check Java version

### APK Not Generated
1. Check if build completed successfully
2. Verify the APK path in the workflow
3. Check disk space on runner

### Artifacts Not Uploading
1. Verify APK was built
2. Check artifact path is correct
3. Ensure artifact name is unique

## 📊 Workflow Status

**Current Status**: ✅ Active and Ready

**Last Run**: Check GitHub Actions page
**Success Rate**: Monitor on Actions page

## 🔗 Links

- **Repository**: https://github.com/saketh-nandu/compass
- **Actions**: https://github.com/saketh-nandu/compass/actions
- **Releases**: https://github.com/saketh-nandu/compass/releases
- **Workflow File**: `.github/workflows/build-apk.yml`

## 📝 Next Steps

1. ✅ Workflow is configured
2. Push code to trigger builds
3. Monitor builds in GitHub Actions
4. Download APKs from artifacts
5. Test on Android devices

## 🎯 Tips

- **Tag releases**: Create a git tag to trigger release builds
- **Monitor logs**: Check logs for any warnings or errors
- **Keep dependencies updated**: Regularly update Flutter and dependencies
- **Test locally first**: Run `flutter build apk` locally before pushing

## 📞 Support

For GitHub Actions help:
- GitHub Actions Docs: https://docs.github.com/en/actions
- Flutter CI/CD: https://flutter.dev/docs/deployment/cd
- Workflow Syntax: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
