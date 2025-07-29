import Foundation

struct Constants {
    // MARK: - Firebase Configuration
    static let firebaseProjectID = "weatherwiseai-007"
    static let bundleIdentifier = "com.keepingupwithtechnology.weatherwiseai"
    
    // MARK: - UI Constants
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let iconSize: CGFloat = 24
        static let largeIconSize: CGFloat = 48
    }
    
    // MARK: - Weather Defaults
    struct Weather {
        static let defaultTempRange = [15, 25] // Celsius
        static let defaultMaxWind = 20 // km/h
        static let defaultMaxRain = 30 // percentage
        static let cacheExpirationMinutes = 10
    }
    
    // MARK: - Activity Defaults
    struct Activity {
        static let commonActivities = [
            "Biking", "Hiking", "Running", "Tennis", "Golf", "Soccer", 
            "Baseball", "Basketball", "Swimming", "Kayaking", "Fishing", 
            "Picnic", "Walking", "Photography", "Gardening", "Camping"
        ]
        
        static let defaultDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    }
    
    // MARK: - Time Formats
    struct TimeFormat {
        static let hourMinute = "HH:mm"
        static let dayName = "EEEE"
        static let shortDate = "MMM d"
        static let fullDate = "EEEE, MMMM d"
    }
}

// MARK: - App Configuration
extension Constants {
    static var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    /// WeatherKit is available on iOS 16+ and doesn't require API keys
    static var isWeatherServiceAvailable: Bool {
        if #available(iOS 16.0, *) {
            return true
        } else {
            return false
        }
    }
}
