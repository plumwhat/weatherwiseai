<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# WeatherWiseAI iOS App Development Instructions

This is an iOS SwiftUI application that provides weather-based activity recommendations.

## Key Technologies
- SwiftUI for UI framework
- Firebase for authentication and database (Firestore)
- OpenWeatherMap API for weather data
- CoreLocation for location services
- MVVM architecture pattern

## Project Structure
- Use MVVM architecture with ViewModels for each major screen
- Implement proper data flow with @StateObject, @ObservedObject, and @EnvironmentObject
- Use async/await for all network operations and Firebase interactions
- Follow SwiftUI best practices for state management and data binding

## Code Style Guidelines
- Use descriptive variable and function names
- Follow Swift naming conventions (camelCase for properties/methods, PascalCase for types)
- Implement proper error handling with do-catch blocks for async operations
- Use Swift's type safety features extensively
- Comment complex business logic, especially in the RecommendationEngine

## Firebase Integration
- All Firestore operations should be async and handle errors appropriately
- Use Codable conformance for data models to work seamlessly with Firestore
- Implement proper user authentication state management
- Use sub-collections for user activities under the user's document

## Weather API Integration
- Implement proper API key management
- Cache weather data to minimize API calls
- Handle network failures gracefully with user-friendly error messages
- Map OpenWeatherMap icons to SF Symbols for native iOS feel

## Testing Considerations
- Write unit tests for ViewModels and Services
- Use dependency injection to make services testable
- Mock Firebase and Weather API for testing
- Test recommendation engine logic thoroughly with various weather scenarios
