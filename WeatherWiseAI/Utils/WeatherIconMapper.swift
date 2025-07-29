import Foundation
import WeatherKit

struct WeatherIconMapper {
    /// Maps WeatherKit WeatherCondition to SF Symbol names
    @available(iOS 16.0, *)
    static func sfSymbolName(for condition: WeatherCondition) -> String {
        switch condition {
        // Clear conditions
        case .clear:
            return "sun.max.fill"
        case .mostlyClear:
            return "sun.max.fill"
        
        // Cloudy conditions
        case .partlyCloudy:
            return "cloud.sun.fill"
        case .mostlyCloudy:
            return "cloud.fill"
        case .cloudy:
            return "smoke.fill"
        
        // Precipitation
        case .drizzle:
            return "cloud.drizzle.fill"
        case .rain:
            return "cloud.rain.fill"
        case .heavyRain:
            return "cloud.heavyrain.fill"
        case .isolatedThunderstorms, .scatteredThunderstorms, .strongThunderstorms:
            return "cloud.bolt.fill"
        
        // Snow conditions
        case .flurries, .snow, .heavySnow:
            return "cloud.snow.fill"
        case .sleet:
            return "cloud.sleet.fill"
        case .freezingDrizzle, .freezingRain:
            return "cloud.sleet.fill"
        
        // Atmospheric conditions
        case .foggy:
            return "cloud.fog.fill"
        case .haze:
            return "sun.haze.fill"
        case .smoky:
            return "smoke.fill"
        case .blustery:
            return "wind"
        case .windy:
            return "wind"
        
        // Extreme conditions
        case .hurricane:
            return "hurricane"
        case .tropicalStorm:
            return "tropicalstorm"
        case .blizzard:
            return "wind.snow"
        
        default:
            return "questionmark.circle.fill"
        }
    }
    
    /// Legacy method for string-based icon codes (for backward compatibility)
    static func sfSymbolName(for iconCode: String) -> String {
        switch iconCode {
        // Clear sky
        case "01d": return "sun.max.fill"
        case "01n": return "moon.fill"
        
        // Few clouds
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        
        // Scattered clouds
        case "03d", "03n": return "cloud.fill"
        
        // Broken clouds
        case "04d", "04n": return "smoke.fill"
        
        // Shower rain
        case "09d", "09n": return "cloud.rain.fill"
        
        // Rain
        case "10d": return "cloud.sun.rain.fill"
        case "10n": return "cloud.moon.rain.fill"
        
        // Thunderstorm
        case "11d", "11n": return "cloud.bolt.fill"
        
        // Snow
        case "13d", "13n": return "cloud.snow.fill"
        
        // Mist/Fog
        case "50d", "50n": return "cloud.fog.fill"
        
        default: return "questionmark.circle.fill"
        }
    }
    
    /// Gets SF Symbol name for suitability status
    static func suitabilityIcon(for level: ActivityRecommendation.SuitabilityLevel) -> String {
        switch level {
        case .good: return "checkmark.circle.fill"
        case .possible: return "exclamationmark.triangle.fill"
        case .notRecommended: return "xmark.circle.fill"
        }
    }
    
    /// Gets activity-specific SF Symbol name
    static func activityIcon(for activityName: String) -> String {
        let name = activityName.lowercased()
        
        switch name {
        case let x where x.contains("bike") || x.contains("cycling"):
            return "bicycle"
        case let x where x.contains("run") || x.contains("jog"):
            return "figure.run"
        case let x where x.contains("hik"):
            return "figure.hiking"
        case let x where x.contains("tennis"):
            return "tennisball.fill"
        case let x where x.contains("golf"):
            return "figure.golf"
        case let x where x.contains("swim"):
            return "figure.pool.swim"
        case let x where x.contains("walk"):
            return "figure.walk"
        case let x where x.contains("soccer") || x.contains("football"):
            return "soccerball"
        case let x where x.contains("basketball"):
            return "basketball.fill"
        case let x where x.contains("baseball"):
            return "baseball.fill"
        case let x where x.contains("fish"):
            return "fish.fill"
        case let x where x.contains("camp"):
            return "tent.fill"
        case let x where x.contains("photo"):
            return "camera.fill"
        case let x where x.contains("garden"):
            return "leaf.fill"
        case let x where x.contains("picnic"):
            return "basket.fill"
        default:
            return "figure.outdoor.cycle"
        }
    }
}
