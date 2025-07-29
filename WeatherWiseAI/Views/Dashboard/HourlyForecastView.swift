import SwiftUI

struct HourlyForecastView: View {
    let forecastDay: ForecastDay
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Day Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(forecastDay.day)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(forecastDay.date.shortDate())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 16) {
                            Image(systemName: forecastDay.icon)
                                .font(.title)
                                .foregroundColor(.accentColor)
                            
                            Text("\(Int(forecastDay.high))° / \(Int(forecastDay.low))°")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .cardStyle()
                    
                    // Hourly Data
                    if !forecastDay.hourly.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Hourly Forecast")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            LazyVStack(spacing: 1) {
                                ForEach(forecastDay.hourly) { hourlyData in
                                    HourlyDataRow(hourlyData: hourlyData)
                                }
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Hourly Forecast")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct HourlyDataRow: View {
    let hourlyData: HourlyData
    
    var body: some View {
        HStack {
            // Time
            Text(hourlyData.time)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 60, alignment: .leading)
            
            Spacer()
            
            // Temperature
            Text(hourlyData.temp.temperatureString)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 50, alignment: .center)
            
            // Wind
            HStack(spacing: 4) {
                Image(systemName: "wind")
                    .font(.caption)
                Text("\(Int(hourlyData.wind))")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            .frame(width: 60, alignment: .center)
            
            // Rain
            HStack(spacing: 4) {
                Image(systemName: "cloud.rain.fill")
                    .font(.caption)
                Text("\(hourlyData.rain)%")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            .frame(width: 60, alignment: .center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview
struct HourlyForecastView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleHourly = [
            HourlyData(time: "09:00", temp: 18.5, rain: 10, wind: 12.0),
            HourlyData(time: "12:00", temp: 22.3, rain: 5, wind: 15.0),
            HourlyData(time: "15:00", temp: 25.1, rain: 20, wind: 18.0),
            HourlyData(time: "18:00", temp: 21.7, rain: 15, wind: 10.0)
        ]
        
        let sampleDay = ForecastDay(
            date: Date(),
            day: "Today",
            high: 25.1,
            low: 18.5,
            wind: 18.0,
            rainChance: 20,
            icon: "cloud.sun.fill",
            hourly: sampleHourly
        )
        
        HourlyForecastView(forecastDay: sampleDay)
    }
}
