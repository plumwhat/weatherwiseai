import Foundation
import SwiftUI

// MARK: - Date Extensions
extension Date {
    func dayName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    
    func shortDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
    
    func timeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func isTomorrow() -> Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
}

// MARK: - String Extensions
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

// MARK: - Double Extensions
extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    var temperatureString: String {
        return "\(Int(self.rounded()))°"
    }
    
    var windSpeedString: String {
        return "\(Int(self.rounded())) km/h"
    }
}

// MARK: - Color Extensions
extension Color {
    static let weatherBlue = Color(red: 0.4, green: 0.7, blue: 1.0)
    static let weatherGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let weatherOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let weatherRed = Color(red: 1.0, green: 0.3, blue: 0.3)
    
    static func suitabilityColor(for level: ActivityRecommendation.SuitabilityLevel) -> Color {
        switch level {
        case .good: return .weatherGreen
        case .possible: return .weatherOrange
        case .notRecommended: return .weatherRed
        }
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(Constants.UI.cornerRadius)
            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    func buttonStyle() -> some View {
        self
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(Constants.UI.cornerRadius)
    }
    
    func fieldStyle() -> some View {
        self
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
    }
}

// MARK: - Bundle Extensions
extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
               object(forInfoDictionaryKey: "CFBundleName") as? String
    }
    
    var appVersion: String? {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    var buildNumber: String? {
        return object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}

// MARK: - Array Extensions
extension Array where Element == Activity {
    func groupedByLocation() -> [String: [Activity]] {
        return Dictionary(grouping: self) { $0.location }
    }
    
    func uniqueLocations() -> [String] {
        return Array(Set(self.map { $0.location })).sorted()
    }
}

// MARK: - UserDefaults Extensions
extension UserDefaults {
    private enum Keys {
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let lastWeatherUpdate = "lastWeatherUpdate"
        static let selectedTemperatureUnit = "selectedTemperatureUnit"
    }
    
    var hasLaunchedBefore: Bool {
        get { bool(forKey: Keys.hasLaunchedBefore) }
        set { set(newValue, forKey: Keys.hasLaunchedBefore) }
    }
    
    var lastWeatherUpdate: Date? {
        get { object(forKey: Keys.lastWeatherUpdate) as? Date }
        set { set(newValue, forKey: Keys.lastWeatherUpdate) }
    }
    
    var selectedTemperatureUnit: String {
        get { string(forKey: Keys.selectedTemperatureUnit) ?? "celsius" }
        set { set(newValue, forKey: Keys.selectedTemperatureUnit) }
    }
}

// MARK: - Error Extensions
extension Error {
    var localizedDescription: String {
        return (self as NSError).localizedDescription
    }
}
