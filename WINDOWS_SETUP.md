# WeatherWiseAI Development Environment

## Windows PowerShell Setup Commands

# Install GitHub CLI
winget install GitHub.cli

# Install Git (if not already installed)
winget install Git.Git

# Clone repository
git clone https://github.com/yourusername/weatherwiseai.git
cd weatherwiseai

# Authenticate with GitHub
gh auth login

# Create and push initial repository structure
git add .
git commit -m "Initial WeatherWiseAI project setup with GitHub Actions CI/CD"
git push origin main

# Monitor first deployment
gh workflow run ios-ci.yml --ref main
gh run watch

## Required Files Checklist

✅ .github/workflows/ios-ci.yml - GitHub Actions workflow
✅ ExportOptions.plist - iOS export configuration  
✅ DEPLOYMENT_GUIDE.md - Complete setup instructions
✅ README.md - Updated project documentation
✅ setup.sh - macOS local development script

## GitHub Secrets Setup

Run these commands after setting up Apple Developer account:

```powershell
# Set GitHub secrets (replace with your values)
gh secret set BUILD_CERTIFICATE_BASE64 --body "your_base64_certificate"
gh secret set P12_PASSWORD --body "your_certificate_password"  
gh secret set BUILD_PROVISION_PROFILE_BASE64 --body "your_base64_profile"
gh secret set KEYCHAIN_PASSWORD --body "random_secure_password"
gh secret set APPSTORE_CONNECT_USERNAME --body "your_apple_id@email.com"
gh secret set APPSTORE_CONNECT_PASSWORD --body "your_app_specific_password"
gh secret set APPSTORE_CONNECT_TEAM_ID --body "your_team_id"
```

## Local Development Options

### Option 1: Cloud Development (Recommended for Windows)
- GitHub Codespaces with macOS environment
- Cloud-based Xcode development
- No local macOS required

### Option 2: Remote Mac Setup  
- Rent Mac mini from MacStadium
- VNC/Screen sharing for remote development
- Full Xcode access

### Option 3: Virtual Machine (Advanced)
- VMware Fusion with macOS
- Requires powerful Windows machine
- Legal considerations for macOS licensing

## Workflow Commands

```powershell
# Check deployment status
gh run list --workflow=ios-ci.yml --limit 5

# View workflow logs  
gh run view --log

# Manual TestFlight deployment
gh workflow run ios-ci.yml --ref main -f deploy_to_testflight=true

# Create feature branch and deploy
git checkout -b feature/new-weather-alerts
# Make changes
git add .
git commit -m "Add weather alert notifications"
git push origin feature/new-weather-alerts
# Create PR automatically triggers tests
gh pr create --title "Weather Alerts Feature" --body "Adds notification system for severe weather"
```

## Firebase Setup Commands

```powershell
# Install Firebase CLI  
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize project
firebase init

# Deploy Firebase rules
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

## Monitoring Commands

```powershell
# Check GitHub Actions status
gh api repos/:owner/:repo/actions/runs

# View Firebase logs
firebase functions:log

# Monitor TestFlight builds
# Use TestFlight iOS app or App Store Connect web interface
```

## Troubleshooting

```powershell
# Clear GitHub Actions cache
gh api repos/:owner/:repo/actions/caches --method DELETE

# Reset workflow
git push --force-with-lease origin main

# Check repository status
gh repo view --web
```

## Success Indicators

- ✅ GitHub Actions workflow passes tests
- ✅ Build uploads to TestFlight successfully  
- ✅ Firebase services connected and working
- ✅ WeatherKit integration functional on iOS 16+
- ✅ App installs and runs from TestFlight

Your Windows → iOS development pipeline is now complete! 🚀
