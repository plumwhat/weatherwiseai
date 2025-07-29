# WeatherWiseAI iOS Project

## Project Overview
WeatherWiseAI is an intelligent iOS app that provides personalized activity recommendations based on real-time weather conditions using Apple's WeatherKit API and Firebase for user management.

## Architecture
- **Framework**: SwiftUI with iOS 16+ requirement
- **Architecture Pattern**: MVVM (Model-View-ViewModel)
- **Weather Service**: Apple WeatherKit (iOS 16+)
- **Backend**: Firebase Authentication & Firestore
- **Deployment**: GitHub Actions → TestFlight → App Store

## Key Features
- 🌤️ Real-time weather data using Apple WeatherKit
- 🎯 AI-powered activity recommendations
- 👤 User authentication and profiles
- 📱 Native iOS SwiftUI interface
- 📊 Activity tracking and history
- 🔔 Weather-based notifications

## Technologies Used

- **Frontend**: SwiftUI, iOS 16+
- **Backend**: Firebase (Authentication, Firestore Database)
- **Weather API**: Apple WeatherKit (iOS 16+)
- **Architecture**: MVVM (Model-View-ViewModel)
- **Language**: Swift 5.5+ (async/await support)

## Project Structure

```
WeatherWiseAI/
├── WeatherWiseAI/
│   ├── WeatherWiseAIApp.swift           # App entry point
│   ├── Models/                          # Data models
│   │   ├── AppUser.swift
│   │   ├── Activity.swift
│   │   ├── WeatherData.swift
│   │   └── TimeSlot.swift
│   ├── Views/                           # SwiftUI Views
│   │   ├── Authentication/
│   │   │   └── SignInView.swift
│   │   ├── Dashboard/
│   │   │   ├── DashboardView.swift
│   │   │   ├── ForecastView.swift
│   │   │   └── RecommendationsView.swift
│   │   ├── Activities/
│   │   │   ├── MyActivitiesView.swift
│   │   │   ├── ActivityFormView.swift
│   │   │   └── ActivityDetailView.swift
│   │   └── Profile/
│   │       └── ProfileView.swift
│   ├── ViewModels/                      # MVVM ViewModels
│   │   ├── SignInViewModel.swift
│   │   ├── DashboardViewModel.swift
│   │   ├── MyActivitiesViewModel.swift
│   │   └── ActivityFormViewModel.swift
│   ├── Services/                        # Business logic and API services
│   │   ├── AuthManager.swift
│   │   ├── FirestoreService.swift
│   │   ├── WeatherService.swift
│   │   ├── LocationManager.swift
│   │   └── RecommendationEngine.swift
│   └── Utils/                           # Utility functions and extensions
│       ├── Constants.swift
│       ├── Extensions.swift
│       └── WeatherIconMapper.swift
├── WeatherWiseAITests/                  # Unit tests
└── WeatherWiseAIUITests/                # UI tests
```

## Setup Instructions

### Prerequisites
- Xcode 14+ 
- iOS 16+ deployment target (required for WeatherKit)
- Firebase project with Firestore and Authentication enabled

### Firebase Setup
1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable Authentication (Email/Password provider)
3. Create a Firestore database
4. Download `GoogleService-Info.plist` and add it to your Xcode project

### Environment Configuration
1. Add location permissions to `Info.plist`
2. Ensure `GoogleService-Info.plist` is properly included in the app bundle
3. WeatherKit is automatically available on iOS 16+ devices (no API key required)

### Dependencies
The app uses Swift Package Manager with the following dependencies:
- Firebase iOS SDK (FirebaseAuth, FirebaseFirestore, FirebaseFirestoreSwift)

## Architecture Overview

### MVVM Pattern
- **Models**: Data structures conforming to `Codable` and `Identifiable`
- **Views**: SwiftUI views for UI presentation
- **ViewModels**: Business logic and state management, using `@Published` properties

### State Management
- `@StateObject` for ViewModel ownership
- `@ObservedObject` for ViewModel observation
- `@EnvironmentObject` for shared state (AuthManager)

### Data Flow
1. Views observe ViewModels
2. ViewModels interact with Services
3. Services handle Firebase/API communication
4. Models represent data structures

## Key Features Implementation

### Authentication Flow
- Email/password authentication with Firebase Auth
- Automatic account creation if user doesn't exist
- Default activities added for new users

### Weather Integration
- Apple WeatherKit for current conditions and 5-day forecast
- Location-based weather using CoreLocation
- Automatic weather data caching
- Native SF Symbols for weather icons

### Activity Recommendations
- Algorithm compares user activity preferences with weather forecasts
- Analyzes temperature, wind speed, and precipitation
- Provides detailed explanations for recommendations

## Testing Strategy

### Unit Tests
- ViewModel business logic
- Service layer functions
- Recommendation algorithm

### UI Tests
- User authentication flow
- Activity creation and editing
- Weather data display

## Deployment

### Echo Integration
The project is configured for deployment using Echo with the following features:
- Automated testing pipeline
- Continuous integration
- App Store deployment automation

### Build Configuration
- Development, Staging, and Production environments
- Proper Firebase configuration per environment
- API key management

## Contributing

1. Follow Swift coding conventions
2. Write unit tests for new features
3. Update documentation for significant changes
4. Use meaningful commit messages

## License

MIT License - see LICENSE file for details
