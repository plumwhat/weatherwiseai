# WeatherWiseAI - Windows to iOS Deployment Guide

## Quick Start Checklist

### 1. Prerequisites Setup
- [ ] GitHub repository created
- [ ] Apple Developer Account ($99/year)
- [ ] Firebase project configured
- [ ] Windows development environment ready

### 2. Apple Developer Setup
- [ ] iOS App ID created: `com.yourcompany.weatherwiseai`
- [ ] Distribution certificate generated
- [ ] Provisioning profile created for App Store distribution
- [ ] App Store Connect app created

### 3. GitHub Secrets Configuration
Go to GitHub → Settings → Secrets and variables → Actions:

```bash
# Required secrets:
BUILD_CERTIFICATE_BASE64     # Your .p12 certificate (base64 encoded)
P12_PASSWORD                 # Certificate password
BUILD_PROVISION_PROFILE_BASE64 # .mobileprovision file (base64 encoded)
KEYCHAIN_PASSWORD           # Random secure password for keychain

# App Store Connect:
APPSTORE_CONNECT_USERNAME   # Your Apple ID
APPSTORE_CONNECT_PASSWORD   # App-specific password
APPSTORE_CONNECT_TEAM_ID    # Your team ID

# Firebase:
FIREBASE_PROJECT_ID_DEV     # weatherwiseai-dev
FIREBASE_PROJECT_ID_PROD    # weatherwiseai-prod
```

### 4. Encoding Certificates for GitHub Secrets

On macOS (or use online base64 encoder):
```bash
# Encode certificate
base64 -i certificate.p12 | pbcopy

# Encode provisioning profile
base64 -i WeatherWiseAI.mobileprovision | pbcopy
```

### 5. Firebase Setup Steps

1. Create Firebase project at https://console.firebase.google.com
2. Add iOS app with bundle ID: `com.yourcompany.weatherwiseai`
3. Download `GoogleService-Info.plist`
4. Place in `ios/WeatherWiseAI/` folder
5. Enable Authentication, Firestore, Analytics, Crashlytics

### 6. Local Development (Windows)

```bash
# Clone and setup
git clone https://github.com/yourusername/weatherwiseai.git
cd weatherwiseai

# Make changes
code .
# Edit Swift files, commit changes

# Deploy
git add .
git commit -m "Feature: Add weather recommendations"
git push origin main

# Monitor deployment
# Visit: https://github.com/yourusername/weatherwiseai/actions
```

### 7. Manual Deployment Trigger

```bash
# Install GitHub CLI on Windows
winget install GitHub.cli

# Authenticate
gh auth login

# Trigger TestFlight deployment
gh workflow run ios-ci.yml --ref main -f deploy_to_testflight=true

# Check status
gh run list --workflow=ios-ci.yml --limit 5
```

### 8. Monitoring Deployment

1. **GitHub Actions**: https://github.com/yourusername/repo/actions
2. **App Store Connect**: https://appstoreconnect.apple.com
3. **Firebase Console**: https://console.firebase.google.com
4. **TestFlight**: iOS TestFlight app

### 9. Common Issues & Solutions

**Build fails with signing error:**
```bash
# Check certificate expiration
# Regenerate provisioning profile
# Update GitHub secrets
```

**Tests fail:**
```bash
# Check iOS simulator availability
# Verify test dependencies
# Update test schemes
```

**Upload to TestFlight fails:**
```bash
# Verify App Store Connect credentials
# Check app version conflicts
# Ensure Export Options are correct
```

### 10. Development Workflow

```bash
# Feature branch workflow
git checkout -b feature/weather-alerts
# Make changes
git commit -m "Add weather alert notifications"
git push origin feature/weather-alerts

# Create PR - triggers tests
# Merge to main - triggers TestFlight deployment
```

### 11. Environment Management

**Development builds** (from `develop` branch):
- Firebase project: `weatherwiseai-dev`
- Internal testing only

**Production builds** (from `main` branch):
- Firebase project: `weatherwiseai-prod`
- TestFlight → App Store

### 12. Fastlane Alternative (Optional)

If you prefer Fastlane for more control:

```bash
# In GitHub Actions runner
gem install fastlane

# ios/fastlane/Fastfile
lane :beta do
  increment_build_number
  build_app(scheme: "WeatherWiseAI")
  upload_to_testflight
end
```

### 13. Monitoring & Analytics

**Firebase Analytics Events:**
- `app_launch`
- `weather_requested`
- `activity_recommended`
- `user_signup`

**Performance Monitoring:**
- Weather API call duration
- App startup time
- Memory usage tracking

**Crashlytics:**
- Automatic crash reporting
- Custom error logging
- Performance regression detection

### 14. Success Metrics

- ✅ Automated testing on every PR
- ✅ Automatic TestFlight deployment from main
- ✅ Zero-downtime deployments
- ✅ Real-time crash monitoring
- ✅ Performance tracking
- ✅ User analytics collection

## Next Steps

1. **Setup Apple Developer Account** and create certificates
2. **Configure GitHub secrets** with your certificates
3. **Create Firebase project** and add configuration
4. **Push code to GitHub** and watch automation work
5. **Test on TestFlight** and iterate

Your Windows → iOS deployment pipeline is now ready! 🚀
