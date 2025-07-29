import SwiftUI

struct WeatherRecommendationsView: View {
    @EnvironmentObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Activity Recommendations")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if viewModel.isLoadingRecommendations {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if viewModel.recommendations.isEmpty && !viewModel.isLoadingRecommendations {
                EmptyRecommendationsView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.recommendations) { recommendation in
                        RecommendationCard(recommendation: recommendation)
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

struct RecommendationCard: View {
    let recommendation: ActivityRecommendation
    @State private var showingDetails = false
    
    var body: some View {
        Button(action: {
            showingDetails = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: WeatherIconMapper.activityIcon(for: recommendation.activity.name))
                            .foregroundColor(.accentColor)
                        
                        Text(recommendation.activity.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    Text(recommendation.activity.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let firstReason = recommendation.reasons.first {
                        Text(firstReason)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: recommendation.suitability.iconName)
                        .font(.title2)
                        .foregroundColor(Color.suitabilityColor(for: recommendation.suitability))
                    
                    Text(recommendation.suitability.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color.suitabilityColor(for: recommendation.suitability))
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetails) {
            RecommendationDetailView(recommendation: recommendation)
        }
    }
}

struct EmptyRecommendationsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.outdoor.cycle")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("No Activities Found")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("Add some activities to get weather recommendations")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

struct RecommendationDetailView: View {
    let recommendation: ActivityRecommendation
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Activity Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: WeatherIconMapper.activityIcon(for: recommendation.activity.name))
                                .font(.title)
                                .foregroundColor(.accentColor)
                            
                            Text(recommendation.activity.name)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Text(recommendation.activity.location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Suitability Status
                    HStack {
                        Image(systemName: recommendation.suitability.iconName)
                            .font(.title3)
                            .foregroundColor(Color.suitabilityColor(for: recommendation.suitability))
                        
                        Text(recommendation.suitability.rawValue)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.suitabilityColor(for: recommendation.suitability))
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.suitabilityColor(for: recommendation.suitability).opacity(0.1))
                    .cornerRadius(8)
                    
                    // Reasons
                    if !recommendation.reasons.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Analysis")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            ForEach(recommendation.reasons, id: \.self) { reason in
                                HStack(alignment: .top) {
                                    Image(systemName: "circle.fill")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 4)
                                    
                                    Text(reason)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    
                    // Time Slot Analysis
                    if !recommendation.timeSlotAnalysis.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Time Slot Details")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            ForEach(recommendation.timeSlotAnalysis) { analysis in
                                TimeSlotAnalysisView(analysis: analysis)
                            }
                        }
                    }
                    
                    // Activity Preferences
                    ActivityPreferencesView(activity: recommendation.activity)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Recommendation Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct TimeSlotAnalysisView: View {
    let analysis: TimeSlotAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(analysis.timeSlot.start) - \(analysis.timeSlot.end)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: analysis.isGood ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(analysis.isGood ? .green : .red)
            }
            
            if !analysis.issues.isEmpty {
                ForEach(analysis.issues, id: \.self) { issue in
                    HStack(alignment: .top) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text(issue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ActivityPreferencesView: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Preferences")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                PreferenceRow(
                    icon: "thermometer",
                    label: "Temperature Range",
                    value: "\(activity.minTemp)° - \(activity.maxTemp)°C"
                )
                
                PreferenceRow(
                    icon: "wind",
                    label: "Max Wind",
                    value: "\(activity.maxWind) km/h"
                )
                
                PreferenceRow(
                    icon: "cloud.rain.fill",
                    label: "Max Rain Chance",
                    value: "\(activity.maxRain)%"
                )
                
                PreferenceRow(
                    icon: "calendar",
                    label: "Days",
                    value: activity.days.joined(separator: ", ")
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct PreferenceRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(.blue)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}
