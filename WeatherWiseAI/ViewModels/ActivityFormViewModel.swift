import Foundation
import Combine

@MainActor
class ActivityFormViewModel: ObservableObject {
    @Published var activityName = ""
    @Published var customActivityName = ""
    @Published var isUsingCustomName = false
    @Published var location = ""
    @Published var minTemperature = 15.0
    @Published var maxTemperature = 25.0
    @Published var maxWind = 20.0
    @Published var maxRain = 30.0
    @Published var timeSlots: [TimeSlot] = []
    @Published var selectedDays: Set<String> = []
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showingError = false
    
    private let firestoreService = FirestoreService.shared
    private let authManager: AuthManager
    private var editingActivity: Activity?
    
    let commonActivities = Constants.Activity.commonActivities
    let availableDays = Constants.Activity.defaultDays
    
    init(authManager: AuthManager, activity: Activity? = nil) {
        self.authManager = authManager
        self.editingActivity = activity
        
        if let activity = activity {
            loadActivity(activity)
        } else {
            setupDefaults()
        }
    }
    
    var isFormValid: Bool {
        let finalActivityName = isUsingCustomName ? customActivityName : activityName
        return !finalActivityName.isEmpty &&
               !location.isEmpty &&
               !timeSlots.isEmpty &&
               !selectedDays.isEmpty &&
               minTemperature < maxTemperature
    }
    
    var isEditMode: Bool {
        return editingActivity != nil
    }
    
    var saveButtonTitle: String {
        return isEditMode ? "Update Activity" : "Save Activity"
    }
    
    private func setupDefaults() {
        timeSlots = [TimeSlot(start: "09:00", end: "17:00")]
        selectedDays = Set(["Saturday", "Sunday"])
    }
    
    private func loadActivity(_ activity: Activity) {
        // Check if activity name is in common activities
        if commonActivities.contains(activity.name) {
            activityName = activity.name
            isUsingCustomName = false
        } else {
            customActivityName = activity.name
            isUsingCustomName = true
        }
        
        location = activity.location
        minTemperature = Double(activity.minTemp)
        maxTemperature = Double(activity.maxTemp)
        maxWind = Double(activity.maxWind)
        maxRain = Double(activity.maxRain)
        timeSlots = activity.timeSlots
        selectedDays = Set(activity.days)
    }
    
    func addTimeSlot() {
        let newSlot = TimeSlot(start: "09:00", end: "17:00")
        timeSlots.append(newSlot)
    }
    
    func removeTimeSlot(at index: Int) {
        guard index < timeSlots.count else { return }
        timeSlots.remove(at: index)
    }
    
    func updateTimeSlot(at index: Int, start: String, end: String) {
        guard index < timeSlots.count else { return }
        timeSlots[index] = TimeSlot(start: start, end: end)
    }
    
    func toggleDay(_ day: String) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
    
    func isDaySelected(_ day: String) -> Bool {
        return selectedDays.contains(day)
    }
    
    func saveActivity() async -> Bool {
        guard isFormValid else {
            errorMessage = "Please fill in all required fields"
            showingError = true
            return false
        }
        
        guard let userID = authManager.user?.id else {
            errorMessage = "User not authenticated"
            showingError = true
            return false
        }
        
        isLoading = true
        
        do {
            let finalActivityName = isUsingCustomName ? customActivityName : activityName
            let tempRange = [Int(minTemperature), Int(maxTemperature)]
            
            let activity = Activity(
                id: editingActivity?.id ?? UUID().uuidString,
                name: finalActivityName,
                location: location,
                tempRange: tempRange,
                maxWind: Int(maxWind),
                maxRain: Int(maxRain),
                timeSlots: timeSlots,
                days: Array(selectedDays)
            )
            
            if isEditMode {
                try await firestoreService.updateActivity(activity, for: userID)
            } else {
                try await firestoreService.addActivity(activity, for: userID)
            }
            
            await MainActor.run {
                self.isLoading = false
            }
            
            return true
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to save activity: \(error.localizedDescription)"
                self.showingError = true
                self.isLoading = false
            }
            return false
        }
    }
    
    func clearError() {
        errorMessage = ""
        showingError = false
    }
    
    func resetForm() {
        if !isEditMode {
            activityName = ""
            customActivityName = ""
            isUsingCustomName = false
            location = ""
            setupDefaults()
        }
        clearError()
    }
    
    // MARK: - Validation Helpers
    
    var temperatureRangeIsValid: Bool {
        return minTemperature < maxTemperature
    }
    
    var hasValidTimeSlots: Bool {
        return !timeSlots.isEmpty && timeSlots.allSatisfy { slot in
            slot.start < slot.end
        }
    }
}
