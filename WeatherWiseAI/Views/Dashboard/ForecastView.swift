import SwiftUI

struct ForecastView: View {
    @EnvironmentObject var viewModel: DashboardViewModel
    @StateObject private var locationManager = LocationManager.shared
    @State private var selectedForecastDay: ForecastDay?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Location Input Section
                LocationInputSection()
                    .environmentObject(viewModel)
                    .environmentObject(locationManager)
                
                if viewModel.isLoadingWeather {
                    ProgressView("Loading weather...")
                        .frame(maxWidth: .infinity, minHeight: 100)
                } else if let weather = viewModel.currentWeather {
                    // Current Conditions
                    CurrentConditionsView(weather: weather)
                    
                    // 5-Day Forecast
                    ForecastListView(
                        forecast: weather.forecast,
                        selectedDay: $selectedForecastDay
                    )
                    
                    // Weather Recommendations
                    if !viewModel.recommendations.isEmpty {
                        WeatherRecommendationsView()
                            .environmentObject(viewModel)
                    }
                } else if !viewModel.weatherError.isEmpty {
                    ErrorView(message: viewModel.weatherError) {
                        viewModel.clearWeatherError()
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding()
        }
        .refreshable {
            viewModel.refreshData()
        }
        .sheet(item: $selectedForecastDay) { day in
            HourlyForecastView(forecastDay: day)
        }
    }
}

struct LocationInputSection: View {
    @EnvironmentObject var viewModel: DashboardViewModel
    @EnvironmentObject var locationManager: LocationManager
    @FocusState private var isLocationFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Enter location", text: $viewModel.locationInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isLocationFieldFocused)
                    .onSubmit {
                        viewModel.fetchWeather()
                    }
                
                Button("Get Forecast") {
                    isLocationFieldFocused = false
                    viewModel.fetchWeather()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.locationInput.isEmpty || viewModel.isLoadingWeather)
            }
            
            Button(action: {
                isLocationFieldFocused = false
                viewModel.useCurrentLocation()
            }) {
                HStack {
                    Image(systemName: "location.fill")
                    Text("Use My Location")
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(8)
            }
            .disabled(viewModel.isLoadingWeather)
        }
        .cardStyle()
    }
}

struct CurrentConditionsView: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Current Conditions")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(weather.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                // Weather Icon and Temperature
                VStack {
                    Image(systemName: weather.current.icon)
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)
                    
                    Text(weather.current.temp.temperatureString)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(weather.current.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Weather Details
                VStack(alignment: .leading, spacing: 8) {
                    WeatherDetailRow(
                        icon: "thermometer",
                        label: "Feels Like",
                        value: weather.current.feelsLike.temperatureString
                    )
                    
                    WeatherDetailRow(
                        icon: "humidity.fill",
                        label: "Humidity",
                        value: "\(weather.current.humidity)%"
                    )
                    
                    WeatherDetailRow(
                        icon: "wind",
                        label: "Wind",
                        value: weather.current.wind.windSpeedString
                    )
                    
                    WeatherDetailRow(
                        icon: "cloud.rain.fill",
                        label: "Precipitation",
                        value: "\(weather.current.precipitation)%"
                    )
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

struct WeatherDetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(.blue)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct ForecastListView: View {
    let forecast: [ForecastDay]
    @Binding var selectedDay: ForecastDay?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("5-Day Forecast")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 8) {
                ForEach(forecast.prefix(5)) { day in
                    ForecastDayRow(day: day) {
                        selectedDay = day
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

struct ForecastDayRow: View {
    let day: ForecastDay
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading) {
                    Text(day.day)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(day.date.shortDate())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Image(systemName: day.icon)
                        .font(.title3)
                        .foregroundColor(.accentColor)
                    
                    VStack(alignment: .trailing) {
                        Text("\(Int(day.high))°/\(Int(day.low))°")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "wind")
                                .font(.caption2)
                            Text("\(Int(day.wind)) km/h")
                                .font(.caption2)
                            
                            Image(systemName: "cloud.rain.fill")
                                .font(.caption2)
                            Text("\(day.rainChance)%")
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ErrorView: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Dismiss", action: onDismiss)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .cardStyle()
    }
}

// MARK: - Preview
struct ForecastView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastView()
            .environmentObject(DashboardViewModel(authManager: AuthManager()))
    }
}
