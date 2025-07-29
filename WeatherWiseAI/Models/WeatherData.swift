import Foundation

// MARK: - Weather Data Models

struct WeatherData: Codable {
    let location: String
    let current: CurrentConditions
    let forecast: [ForecastDay]
    let fetchedAt: Date
    
    init(location: String, current: CurrentConditions, forecast: [ForecastDay]) {
        self.location = location
        self.current = current
        self.forecast = forecast
        self.fetchedAt = Date()
    }
}

struct CurrentConditions: Codable {
    let temp: Double
    let feelsLike: Double
    let humidity: Int
    let wind: Double // km/h
    let precipitation: Int // chance of precipitation 0-100
    let description: String
    let icon: String // SF Symbol name
    
    init(temp: Double, feelsLike: Double, humidity: Int, wind: Double, 
         precipitation: Int, description: String, icon: String) {
        self.temp = temp
        self.feelsLike = feelsLike
        self.humidity = humidity
        self.wind = wind
        self.precipitation = precipitation
        self.description = description
        self.icon = icon
    }
}

struct ForecastDay: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let day: String // "Wednesday"
    let high: Double
    let low: Double
    let wind: Double
    let rainChance: Int
    let icon: String // SF Symbol name
    let hourly: [HourlyData]
    
    init(date: Date, day: String, high: Double, low: Double, 
         wind: Double, rainChance: Int, icon: String, hourly: [HourlyData]) {
        self.date = date
        self.day = day
        self.high = high
        self.low = low
        self.wind = wind
        self.rainChance = rainChance
        self.icon = icon
        self.hourly = hourly
    }
}

struct HourlyData: Codable, Identifiable {
    let id = UUID()
    let time: String // "14:00"
    let temp: Double
    let rain: Int // chance percentage
    let wind: Double // km/h
    
    init(time: String, temp: Double, rain: Int, wind: Double) {
        self.time = time
        self.temp = temp
        self.rain = rain
        self.wind = wind
    }
}

// MARK: - Recommendation Models

struct ActivityRecommendation: Identifiable {
    let id = UUID()
    let activity: Activity
    let suitability: SuitabilityLevel
    let reasons: [String]
    let timeSlotAnalysis: [TimeSlotAnalysis]
    
    enum SuitabilityLevel: String, CaseIterable {
        case good = "Good"
        case possible = "Possible"
        case notRecommended = "Not Recommended"
        
        var color: String {
            switch self {
            case .good: return "green"
            case .possible: return "orange"
            case .notRecommended: return "red"
            }
        }
        
        var iconName: String {
            switch self {
            case .good: return "checkmark.circle.fill"
            case .possible: return "exclamationmark.triangle.fill"
            case .notRecommended: return "xmark.circle.fill"
            }
        }
    }
}

struct TimeSlotAnalysis: Identifiable {
    let id = UUID()
    let timeSlot: TimeSlot
    let isGood: Bool
    let issues: [String]
}
