# WeatherWiseAI iOS Development

## Windows-Based iOS Deployment Configuration

### iOS CI/CD Setup for Windows Development

Since you're developing on Windows, we'll use GitHub Actions for iOS deployment instead of the fictional Echo CLI. This approach leverages cloud-based macOS runners for building and deploying iOS apps.

### 1. GitHub Actions Setup

No local installation needed - GitHub Actions runs on GitHub's cloud infrastructure:

```bash
# Initialize git repository if not already done
git init
git remote add origin https://github.com/yourusername/weatherwiseai.git
```

### 2. GitHub Actions Workflow Configuration

Create `.github/workflows/ios-build.yml` in your project root:

```yaml
name: iOS Build and Deploy
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build-ios:
    runs-on: macos-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      
      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: latest-stable
      
      - name: Install dependencies
        run: |
          # Install Firebase dependencies if needed
          pod repo update
          pod install --project-directory=ios
      
      - name: Build for simulator
        run: |
          xcodebuild \
            -workspace WeatherWiseAI.xcworkspace \
            -scheme WeatherWiseAI \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            build
      
      - name: Run unit tests
        run: |
          xcodebuild test \
            -workspace WeatherWiseAI.xcworkspace \
            -scheme WeatherWiseAI \
            -destination 'platform=iOS Simulator,name=iPhone 15'
  
  deploy-testflight:
    needs: build-ios
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      
      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: latest-stable
      
      - name: Install Apple Certificate
        env:
          BUILD_CERTIFICATE_BASE64: ${{ secrets.BUILD_CERTIFICATE_BASE64 }}
          P12_PASSWORD: ${{ secrets.P12_PASSWORD }}
          BUILD_PROVISION_PROFILE_BASE64: ${{ secrets.BUILD_PROVISION_PROFILE_BASE64 }}
          KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
        run: |
          # Create keychain
          security create-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
          security default-keychain -s build.keychain
          security unlock-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
          
          # Import certificate
          echo $BUILD_CERTIFICATE_BASE64 | base64 --decode > certificate.p12
          security import certificate.p12 -k build.keychain -P "$P12_PASSWORD" -T /usr/bin/codesign
          security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" build.keychain
          
          # Install provisioning profile
          echo $BUILD_PROVISION_PROFILE_BASE64 | base64 --decode > WeatherWiseAI.mobileprovision
          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          cp WeatherWiseAI.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles
      
      - name: Build and Archive
        run: |
          xcodebuild archive \
            -workspace WeatherWiseAI.xcworkspace \
            -scheme WeatherWiseAI \
            -archivePath WeatherWiseAI.xcarchive \
            -configuration Release \
            CODE_SIGN_STYLE=Manual
      
      - name: Export IPA
        run: |
          xcodebuild -exportArchive \
            -archivePath WeatherWiseAI.xcarchive \
            -exportOptionsPlist ExportOptions.plist \
            -exportPath ./build
      
      - name: Upload to TestFlight
        env:
          APPSTORE_CONNECT_USERNAME: ${{ secrets.APPSTORE_CONNECT_USERNAME }}
          APPSTORE_CONNECT_PASSWORD: ${{ secrets.APPSTORE_CONNECT_PASSWORD }}
        run: |
          xcrun altool --upload-app \
            --type ios \
            --file "./build/WeatherWiseAI.ipa" \
            --username "$APPSTORE_CONNECT_USERNAME" \
            --password "$APPSTORE_CONNECT_PASSWORD" \
            --verbose
```

### 3. Required GitHub Secrets

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

```bash
# Apple Developer Account
APPSTORE_CONNECT_USERNAME=your_apple_id@email.com
APPSTORE_CONNECT_PASSWORD=your_app_specific_password

# Certificates and Provisioning (Base64 encoded)
BUILD_CERTIFICATE_BASE64=<base64_encoded_p12_certificate>
P12_PASSWORD=<certificate_password>
BUILD_PROVISION_PROFILE_BASE64=<base64_encoded_mobileprovision>
KEYCHAIN_PASSWORD=<random_keychain_password>

# Firebase Configuration
FIREBASE_PROJECT_ID_DEV=weatherwiseai-dev
FIREBASE_PROJECT_ID_PROD=weatherwiseai-prod
```

### 4. Export Options Configuration

Create `ExportOptions.plist` in your project root:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>destination</key>
    <string>upload</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.yourcompany.weatherwiseai</key>
        <string>WeatherWiseAI Distribution Profile</string>
    </dict>
</dict>
</plist>
```

### 5. Windows Development Workflow

From your Windows machine, you can:

```bash
# 1. Develop and commit code
git add .
git commit -m "Add new feature"
git push origin main

# 2. Monitor builds in GitHub Actions
# Visit: https://github.com/yourusername/weatherwiseai/actions

# 3. Local development with simulators (requires macOS VM or remote Mac)
# For Windows, use cloud-based solutions like:
# - GitHub Codespaces with macOS
# - MacStadium or similar cloud Mac services
# - Remote Mac mini setup
```

### 6. Alternative: Fastlane Integration

Install Fastlane for more advanced deployment automation:

```bash
# On your remote Mac or in GitHub Actions
gem install fastlane

# Initialize Fastlane
cd ios
fastlane init
```

Create `ios/fastlane/Fastfile`:

```ruby
default_platform(:ios)

platform :ios do
  desc "Build and upload to TestFlight"
  lane :beta do
    increment_build_number(xcodeproj: "WeatherWiseAI.xcodeproj")
    
    build_app(
      scheme: "WeatherWiseAI",
      export_method: "app-store"
    )
    
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
    
    # Send Slack notification
    slack(
      message: "WeatherWiseAI beta build uploaded to TestFlight!"
    )
  end
  
  desc "Deploy to App Store"
  lane :release do
    build_app(
      scheme: "WeatherWiseAI",
      export_method: "app-store"
    )
    
    upload_to_app_store(
      submit_for_review: false,
      automatic_release: false
    )
  end
end
```

### 7. GitHub Actions Commands

Use GitHub CLI to manage deployments from Windows:

```bash
# Install GitHub CLI on Windows
winget install GitHub.cli

# Trigger manual deployment
gh workflow run ios-build.yml --ref main

# Monitor workflow status
gh run list --workflow=ios-build.yml

# View workflow logs
gh run view --log
```

### 8. Firebase Analytics Integration

Since we're using Apple WeatherKit (no API key needed), focus on Firebase:

```swift
// Add to your WeatherWiseAIApp.swift
import FirebaseAnalytics
import FirebaseCore

@main
struct WeatherWiseAIApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Analytics.logEvent("app_launch", parameters: nil)
                }
        }
    }
}
```

Track events in your ViewModels:

```swift
// Track weather requests
Analytics.logEvent("weather_requested", parameters: [
    "location": locationName,
    "user_id": userId ?? "anonymous"
])

// Track activity recommendations
Analytics.logEvent("recommendation_viewed", parameters: [
    "activity_type": activity.type,
    "weather_condition": weatherData.condition,
    "temperature": weatherData.temperature
])
```

### 9. Performance Monitoring with Firebase

```swift
// Monitor app performance
import FirebasePerformance

class WeatherService: ObservableObject {
    func fetchWeather(for location: CLLocation) async throws -> WeatherData {
        let trace = Performance.startTrace(name: "weather_fetch")
        
        do {
            let weatherData = try await WeatherKit.shared.weather(for: location)
            trace.setValue(weatherData.currentWeather.temperature.value, 
                          forMetric: "temperature")
            trace.stop()
            return mapToWeatherData(weatherData)
        } catch {
            trace.setValue("error", forAttribute: "result")
            trace.stop()
            throw error
        }
    }
}
```

### 10. Firebase Crashlytics

```swift
// Automatic crash reporting
import FirebaseCrashlytics

@main
struct WeatherWiseAIApp: App {
    init() {
        FirebaseApp.configure()
        
        // Enable Crashlytics
        #if !DEBUG
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    Crashlytics.crashlytics().log("App became active")
                }
        }
    }
}

// Log custom errors
extension WeatherService {
    func logWeatherError(_ error: Error, location: String) {
        Crashlytics.crashlytics().log("Weather fetch failed for location: \(location)")
        Crashlytics.crashlytics().record(error: error)
    }
}
```

## Summary

This Windows-based iOS deployment approach provides:
- ✅ GitHub Actions for automated iOS builds on macOS runners
- ✅ No local macOS requirement for deployment
- ✅ Firebase Analytics and Crashlytics integration
- ✅ WeatherKit integration (no API key management needed)
- ✅ Automated TestFlight uploads
- ✅ Environment-specific configurations
- ✅ Real-time monitoring and crash reporting
- ✅ Fastlane integration for advanced workflows
