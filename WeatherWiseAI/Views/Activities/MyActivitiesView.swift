import SwiftUI

struct MyActivitiesView: View {
    @EnvironmentObject var viewModel: MyActivitiesViewModel
    @State private var showingDeleteConfirmation = false
    @State private var activityToDelete: Activity?
    
    var body: some View {
        ZStack {
            if viewModel.activities.isEmpty && !viewModel.isLoading {
                EmptyActivitiesView {
                    viewModel.addActivity()
                }
            } else {
                ActivityListView()
                    .environmentObject(viewModel)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.addActivity()
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .refreshable {
            viewModel.refreshActivities()
        }
        .sheet(isPresented: $viewModel.showingActivityForm) {
            ActivityFormView(activity: viewModel.selectedActivity)
                .onDisappear {
                    viewModel.activityFormDismissed()
                }
        }
        .alert("Delete Activity", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let activity = activityToDelete {
                    viewModel.deleteActivity(activity)
                }
                activityToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                activityToDelete = nil
            }
        } message: {
            if let activity = activityToDelete {
                Text("Are you sure you want to delete '\(activity.name)'? This action cannot be undone.")
            }
        }
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onReceive(NotificationCenter.default.publisher(for: .activityDeleteRequested)) { notification in
            if let activity = notification.object as? Activity {
                activityToDelete = activity
                showingDeleteConfirmation = true
            }
        }
    }
}

struct ActivityListView: View {
    @EnvironmentObject var viewModel: MyActivitiesViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Summary Stats
                ActivityStatsView()
                    .environmentObject(viewModel)
                
                // Activities grouped by location
                ForEach(Array(viewModel.groupedActivities.keys.sorted()), id: \.self) { location in
                    if let activities = viewModel.groupedActivities[location] {
                        ActivityLocationSection(location: location, activities: activities)
                            .environmentObject(viewModel)
                    }
                }
            }
            .padding()
        }
    }
}

struct ActivityStatsView: View {
    @EnvironmentObject var viewModel: MyActivitiesViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            StatCard(
                icon: "figure.outdoor.cycle",
                title: "Total Activities",
                value: "\(viewModel.totalActivities)"
            )
            
            StatCard(
                icon: "location.fill",
                title: "Locations",
                value: "\(viewModel.uniqueLocations)"
            )
        }
        .cardStyle()
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ActivityLocationSection: View {
    let location: String
    let activities: [Activity]
    @EnvironmentObject var viewModel: MyActivitiesViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                
                Text(location)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(activities.count) \(activities.count == 1 ? "activity" : "activities")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(activities) { activity in
                    ActivityCard(activity: activity)
                        .environmentObject(viewModel)
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

struct ActivityCard: View {
    let activity: Activity
    @EnvironmentObject var viewModel: MyActivitiesViewModel
    
    var body: some View {
        HStack {
            // Activity Icon and Name
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: WeatherIconMapper.activityIcon(for: activity.name))
                        .foregroundColor(.accentColor)
                    
                    Text(activity.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                // Activity Details
                VStack(alignment: .leading, spacing: 2) {
                    Text("Temperature: \(activity.minTemp)° - \(activity.maxTemp)°C")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Max Wind: \(activity.maxWind) km/h • Max Rain: \(activity.maxRain)%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !activity.days.isEmpty {
                        Text("Days: \(activity.days.prefix(3).joined(separator: ", "))\(activity.days.count > 3 ? "..." : "")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 8) {
                Button(action: {
                    viewModel.editActivity(activity)
                }) {
                    Image(systemName: "pencil")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
                
                Button(action: {
                    NotificationCenter.default.post(
                        name: .activityDeleteRequested,
                        object: activity
                    )
                }) {
                    Image(systemName: "trash")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct EmptyActivitiesView: View {
    let onAddActivity: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.outdoor.cycle")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Activities Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add your first activity to get personalized weather recommendations")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: onAddActivity) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Activity")
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(Constants.UI.cornerRadius)
            }
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let activityDeleteRequested = Notification.Name("activityDeleteRequested")
}

// MARK: - Preview
struct MyActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MyActivitiesView()
                .environmentObject(MyActivitiesViewModel(authManager: AuthManager()))
        }
    }
}
