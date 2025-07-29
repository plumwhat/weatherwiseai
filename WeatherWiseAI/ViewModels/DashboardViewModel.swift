import Foundation
import Combine
import CoreLocation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var locationInput = ""
    @Published var currentWeather: WeatherData?
    @Published var isLoadingWeather = false
    @Published var weatherError = ""
    @Published var activities: [Activity] = []
    @Published var recommendations: [ActivityRecommendation] = []
    @Published var isLoadingRecommendations = false
    
    private var weatherService: WeatherService? {
        if #available(iOS 16.0, *) {
            return WeatherService.shared
        } else {
            return nil
        }
    }
    private let firestoreService = FirestoreService.shared
    private let locationManager = LocationManager.shared
    private let recommendationEngine = RecommendationEngine.shared
    private let authManager: AuthManager
    
    private var cancellables = Set<AnyCancellable>()
    private var activitiesListener: Any?
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        setupSubscriptions()
        loadUserActivities()
        
        // Check iOS version compatibility
        if #unavailable(iOS 16.0) {
            weatherError = "Weather features require iOS 16 or later"
        }
    }
    
    deinit {
        // Clean up Firestore listener if needed
    }
    
    private func setupSubscriptions() {
        // Listen to location updates
        locationManager.$location
            .compactMap { $0 }
            .sink { [weak self] location in
                Task {
                    await self?.fetchWeatherForLocation(location)
                }
            }
            .store(in: &cancellables)
        
        // Listen to location errors
        locationManager.$errorMessage
            .filter { !$0.isEmpty }
            .assign(to: \.weatherError, on: self)
            .store(in: &cancellables)
    }
    
    func fetchWeather() {
        guard !locationInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            weatherError = "Please enter a location"
            return
        }
        
        guard let weatherService = weatherService else {
            weatherError = "Weather service requires iOS 16 or later"
            return
        }
        
        isLoadingWeather = true
        weatherError = ""
        
        Task {
            do {
                let weather = try await weatherService.fetchWeather(for: locationInput)
                await MainActor.run {
                    self.currentWeather = weather
                    self.isLoadingWeather = false
                    self.generateRecommendations()
                }
            } catch {
                await MainActor.run {
                    self.weatherError = error.localizedDescription
                    self.isLoadingWeather = false
                }
            }
        }
    }
    
    func useCurrentLocation() {
        guard locationManager.authorizationStatus == .authorizedWhenInUse || 
              locationManager.authorizationStatus == .authorizedAlways else {
            locationManager.requestLocationPermission()
            return
        }
        
        locationManager.getCurrentLocation()
    }
    
    private func fetchWeatherForLocation(_ location: CLLocation) async {
        guard let weatherService = weatherService else {
            await MainActor.run {
                self.weatherError = "Weather service requires iOS 16 or later"
            }
            return
        }
        
        isLoadingWeather = true
        weatherError = ""
        
        do {
            let weather = try await weatherService.fetchWeatherForCoordinates(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude
            )
            await MainActor.run {
                self.currentWeather = weather
                self.locationInput = weather.location
                self.isLoadingWeather = false
                self.generateRecommendations()
            }
        } catch {
            await MainActor.run {
                self.weatherError = error.localizedDescription
                self.isLoadingWeather = false
            }
        }
    }
    
    private func loadUserActivities() {
        guard let userID = authManager.user?.id else { return }
        
        Task {
            do {
                let activities = try await firestoreService.fetchActivities(for: userID)
                await MainActor.run {
                    self.activities = activities
                    self.generateRecommendations()
                }
            } catch {
                print("Error loading activities: \(error)")
            }
        }
    }
    
    private func generateRecommendations() {
        guard !activities.isEmpty else { return }
        guard let weatherService = weatherService else {
            print("Weather service not available - requires iOS 16+")
            return
        }
        
        isLoadingRecommendations = true
        
        Task {
            // Get unique locations from activities
            let locations = activities.uniqueLocations()
            
            do {
                // Fetch weather for all activity locations
                let weatherData = try await weatherService.fetchAllWeather(locations: locations)
                
                // Generate recommendations
                let recommendations = recommendationEngine.generateRecommendations(
                    activities: activities,
                    weatherData: weatherData
                )
                
                await MainActor.run {
                    self.recommendations = recommendations
                    self.isLoadingRecommendations = false
                }
            } catch {
                await MainActor.run {
                    print("Error generating recommendations: \(error)")
                    self.isLoadingRecommendations = false
                }
            }
        }
    }
    
    func refreshData() {
        loadUserActivities()
        if currentWeather != nil {
            fetchWeather()
        }
    }
    
    func clearWeatherError() {
        weatherError = ""
    }
}
