# WeatherWiseAI Setup Instructions

## 🚀 Quick Start Guide

### Prerequisites
- Xcode 14+ installed on macOS
- iOS 16+ deployment target (required for WeatherKit)
- Firebase project setup

### 1. Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or use existing one
3. Enable Authentication with Email/Password provider
4. Create a Firestore database
5. Download `GoogleService-Info.plist` and add it to your Xcode project

### 2. WeatherKit Configuration

WeatherKit is Apple's weather service that provides high-quality weather data:

1. **No API Key Required**: WeatherKit is automatically available on iOS 16+ devices
2. **Rate Limits**: 500,000 API calls per month for free
3. **Privacy**: All weather requests are made directly from the user's device
4. **Accuracy**: Powered by Apple's global weather service

**Important Notes:**
- WeatherKit requires iOS 16.0 or later
- The app will show an error message on devices running iOS 15 or earlier
- WeatherKit automatically handles location privacy and user consent

### 3. Xcode Project Setup

Since this is a SwiftUI project, you'll need to:

1. Open Xcode
2. Create a new iOS project with SwiftUI
3. Copy the source files from this VS Code workspace to your Xcode project
4. Add Firebase SDK via Swift Package Manager:
   - `https://github.com/firebase/firebase-ios-sdk.git`
   - Select: FirebaseAuth, FirebaseFirestore, FirebaseFirestoreSwift

### 4. Required Permissions

Add these to your `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>WeatherWiseAI needs location access to provide weather forecasts for your current location.</string>
```

### 5. Echo Deployment Setup

For CI/CD with Echo:

1. Install Echo CLI: `npm install -g @echo-health/cli`
2. Configure your deployment pipeline
3. Set up environment variables for Firebase and API keys
4. Run tests: `echo test`
5. Deploy: `echo deploy`

## 📁 Project Structure

The project follows MVVM architecture:

- **Models/**: Data structures (User, Activity, Weather)
- **Views/**: SwiftUI views organized by feature
- **ViewModels/**: Business logic and state management
- **Services/**: Firebase, Weather API, and business services
- **Utils/**: Helper functions, constants, and extensions

## 🔧 Development Workflow

### Building the Project
```bash
# In VS Code terminal
swift build
```

### Running Tests
```bash
swift test
```

### Code Style
- Follow Swift naming conventions
- Use meaningful variable names
- Comment complex business logic
- Write unit tests for ViewModels and Services

## 🌟 Key Features Implemented

### ✅ Authentication
- Email/password sign-in
- Automatic account creation
- User state management
- Default activities for new users

### ✅ Weather Integration
- OpenWeatherMap API integration
- Current conditions and 5-day forecast
- Location-based weather
- Weather data caching

### ✅ Activity Management
- CRUD operations for activities
- Real-time Firestore sync
- Activity preferences (temp, wind, rain)
- Time slot and day scheduling

### ✅ Smart Recommendations
- Weather-based activity analysis
- Suitability scoring (Good/Possible/Not Recommended)
- Detailed recommendation explanations
- Time slot specific analysis

## 🚨 Important Notes

1. **API Keys**: Never commit real API keys to version control
2. **Firebase Config**: Add `GoogleService-Info.plist` to your Xcode project
3. **Permissions**: Location permission is required for "Use My Location" feature
4. **Testing**: Use mock data when API keys are not configured

## 📱 iOS Deployment

1. Configure signing in Xcode
2. Set deployment target to iOS 15+
3. Test on simulator and physical device
4. Use TestFlight for beta testing
5. Submit to App Store when ready

## 🔍 Troubleshooting

### Common Issues:
- **Firebase not connecting**: Check `GoogleService-Info.plist` is properly added
- **Location not working**: Verify location permissions in Settings
- **Weather not loading**: Confirm OpenWeatherMap API key is valid
- **Activities not syncing**: Check Firestore security rules

### Getting Help:
- Check Firebase Console for errors
- Use Xcode debugger for runtime issues
- Review API responses for weather service problems
- Check VS Code terminal for build errors

---

Your WeatherWiseAI iOS app is now ready for development! 🎉
