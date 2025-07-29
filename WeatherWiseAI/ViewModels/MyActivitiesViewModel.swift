import Foundation
import Combine
import FirebaseFirestore

@MainActor
class MyActivitiesViewModel: ObservableObject {
    @Published var activities: [Activity] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showingError = false
    @Published var showingActivityForm = false
    @Published var selectedActivity: Activity?
    
    private let firestoreService = FirestoreService.shared
    private let authManager: AuthManager
    private var activitiesListener: ListenerRegistration?
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        setupActivitiesListener()
    }
    
    deinit {
        activitiesListener?.remove()
    }
    
    private func setupActivitiesListener() {
        guard let userID = authManager.user?.id else { return }
        
        // Set up real-time listener for activities
        activitiesListener = firestoreService.listenToActivities(for: userID) { [weak self] activities in
            Task { @MainActor in
                self?.activities = activities
            }
        }
    }
    
    func addActivity() {
        selectedActivity = nil
        showingActivityForm = true
    }
    
    func editActivity(_ activity: Activity) {
        selectedActivity = activity
        showingActivityForm = true
    }
    
    func deleteActivity(_ activity: Activity) {
        guard let userID = authManager.user?.id else { return }
        
        isLoading = true
        
        Task {
            do {
                try await firestoreService.deleteActivity(activity.id, for: userID)
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to delete activity: \(error.localizedDescription)"
                    self.showingError = true
                    self.isLoading = false
                }
            }
        }
    }
    
    func refreshActivities() {
        guard let userID = authManager.user?.id else { return }
        
        isLoading = true
        
        Task {
            do {
                let activities = try await firestoreService.fetchActivities(for: userID)
                await MainActor.run {
                    self.activities = activities
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load activities: \(error.localizedDescription)"
                    self.showingError = true
                    self.isLoading = false
                }
            }
        }
    }
    
    func clearError() {
        errorMessage = ""
        showingError = false
    }
    
    func activityFormDismissed() {
        showingActivityForm = false
        selectedActivity = nil
    }
    
    // MARK: - Helper Methods
    
    var groupedActivities: [String: [Activity]] {
        return activities.groupedByLocation()
    }
    
    var totalActivities: Int {
        return activities.count
    }
    
    var uniqueLocations: Int {
        return activities.uniqueLocations().count
    }
}
