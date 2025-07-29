import Foundation
import CoreLocation
import WeatherKit
import MapKit

@available(iOS 16.0, *)
class WeatherService: ObservableObject {
    static let shared = WeatherService()
    
    private let weatherService = WeatherKit.WeatherService()
    private var weatherCache: [String: WeatherData] = [:]
    private let cacheExpiration: TimeInterval = 600 // 10 minutes
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchAllWeather(locations: [String]) async throws -> [String: WeatherData] {
        var results: [String: WeatherData] = [:]
        
        // Process locations concurrently
        await withTaskGroup(of: (String, WeatherData?).self) { group in
            for location in locations {
                group.addTask {
                    do {
                        let weather = try await self.fetchWeather(for: location)
                        return (location, weather)
                    } catch {
                        print("Failed to fetch weather for \(location): \(error)")
                        return (location, nil)
                    }
                }
            }
            
            for await (location, weather) in group {
                if let weather = weather {
                    results[location] = weather
                }
            }
        }
        
        return results
    }
    
    func fetchWeather(for location: String) async throws -> WeatherData {
        // Check cache first
        if let cachedWeather = getCachedWeather(for: location) {
            return cachedWeather
        }
        
        // Get coordinates for location
        let coordinates = try await getCoordinates(for: location)
        
        // Fetch weather using WeatherKit
        let weather = try await weatherService.weather(for: .init(latitude: coordinates.latitude, longitude: coordinates.longitude))
        
        let weatherData = WeatherData(
            location: location,
            current: parseCurrentWeather(from: weather.currentWeather),
            forecast: parseForecast(from: weather.dailyForecast, hourlyForecast: weather.hourlyForecast)
        )
        
        // Cache the result
        cacheWeather(weatherData, for: location)
        
        return weatherData
    }
    
    func fetchWeatherForCoordinates(lat: Double, lon: Double) async throws -> WeatherData {
        let locationKey = "\(lat),\(lon)"
        
        // Check cache first
        if let cachedWeather = getCachedWeather(for: locationKey) {
            return cachedWeather
        }
        
        // Fetch weather using WeatherKit
        let location = CLLocation(latitude: lat, longitude: lon)
        let weather = try await weatherService.weather(for: location)
        
        // Get location name from coordinates
        let locationName = try await getLocationName(lat: lat, lon: lon)
        
        let weatherData = WeatherData(
            location: locationName,
            current: parseCurrentWeather(from: weather.currentWeather),
            forecast: parseForecast(from: weather.dailyForecast, hourlyForecast: weather.hourlyForecast)
        )
        
        // Cache the result
        cacheWeather(weatherData, for: locationKey)
        
        return weatherData
    }
    
    // MARK: - Private Methods
    
    private func getCoordinates(for location: String) async throws -> CLLocationCoordinate2D {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString(location)
        
        guard let coordinate = placemarks.first?.location?.coordinate else {
            throw WeatherError.locationNotFound
        }
        
        return coordinate
    }
    
    private func getLocationName(lat: Double, lon: Double) async throws -> String {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: lat, longitude: lon)
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        
        guard let placemark = placemarks.first else {
            return "Unknown Location"
        }
        
        return placemark.locality ?? placemark.administrativeArea ?? "Unknown Location"
    }
    
    // MARK: - WeatherKit Parsing Methods
    
    private func parseCurrentWeather(from current: CurrentWeather) -> CurrentConditions {
        let temp = current.temperature.value
        let feelsLike = current.apparentTemperature.value
        let humidity = Int(current.humidity * 100)
        let windSpeed = current.wind.speed.value * 3.6 // Convert m/s to km/h
        let precipitation = Int((current.precipitationChance ?? 0) * 100)
        let description = current.condition.description
        let iconName = WeatherIconMapper.sfSymbolName(for: current.condition)
        
        return CurrentConditions(
            temp: temp,
            feelsLike: feelsLike,
            humidity: humidity,
            wind: windSpeed,
            precipitation: precipitation,
            description: description.capitalized,
            icon: iconName
        )
    }
    
    private func parseForecast(from dailyForecast: Forecast<DayWeather>, hourlyForecast: Forecast<HourWeather>) -> [ForecastDay] {
        var forecastDays: [ForecastDay] = []
        
        // Take only the next 5 days
        let nextFiveDays = Array(dailyForecast.prefix(5))
        
        for dayWeather in nextFiveDays {
            let date = dayWeather.date
            let dayName = DateFormatter.dayName.string(from: date)
            
            // Get hourly data for this day
            let dayStart = Calendar.current.startOfDay(for: date)
            let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            
            let hourlyDataForDay = hourlyForecast.filter { hourWeather in
                hourWeather.date >= dayStart && hourWeather.date < dayEnd
            }.map { hourWeather in
                HourlyData(
                    time: DateFormatter.hourMinute.string(from: hourWeather.date),
                    temp: hourWeather.temperature.value,
                    rain: Int((hourWeather.precipitationChance ?? 0) * 100),
                    wind: hourWeather.wind.speed.value * 3.6
                )
            }
            
            let forecastDay = ForecastDay(
                date: date,
                day: dayName,
                high: dayWeather.highTemperature.value,
                low: dayWeather.lowTemperature.value,
                wind: dayWeather.wind.speed.value * 3.6,
                rainChance: Int((dayWeather.precipitationChance ?? 0) * 100),
                icon: WeatherIconMapper.sfSymbolName(for: dayWeather.condition),
                hourly: hourlyDataForDay
            )
            
            forecastDays.append(forecastDay)
        }
        
        return forecastDays
    }
    
    // MARK: - Cache Management
    
    private func getCachedWeather(for location: String) -> WeatherData? {
        guard let cachedWeather = weatherCache[location] else { return nil }
        
        let timeSinceCache = Date().timeIntervalSince(cachedWeather.fetchedAt)
        if timeSinceCache < cacheExpiration {
            return cachedWeather
        } else {
            weatherCache.removeValue(forKey: location)
            return nil
        }
    }
    
    private func cacheWeather(_ weather: WeatherData, for location: String) {
        weatherCache[location] = weather
    }
}

// MARK: - Weather Service Errors

enum WeatherError: LocalizedError {
    case locationNotFound
    case weatherServiceUnavailable
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .locationNotFound:
            return "Location not found"
        case .weatherServiceUnavailable:
            return "Weather service is currently unavailable"
        case .invalidData:
            return "Invalid weather data received"
        }
    }
}

// MARK: - DateFormatter Extensions

extension DateFormatter {
    static let dayKey: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let dayName: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    static let hourMinute: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
