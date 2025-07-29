import Foundation

struct Activity: Codable, Identifiable {
    let id: String
    let name: String
    let location: String
    let tempRange: [Int] // [minTemp, maxTemp]
    let maxWind: Int // km/h
    let maxRain: Int // percentage 0-100
    let timeSlots: [TimeSlot]
    let days: [String] // ["Monday", "Tuesday", etc.]
    let createdAt: Date
    let updatedAt: Date
    
    init(id: String = UUID().uuidString, name: String, location: String, 
         tempRange: [Int], maxWind: Int, maxRain: Int, 
         timeSlots: [TimeSlot], days: [String]) {
        self.id = id
        self.name = name
        self.location = location
        self.tempRange = tempRange
        self.maxWind = maxWind
        self.maxRain = maxRain
        self.timeSlots = timeSlots
        self.days = days
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Computed properties for convenience
    var minTemp: Int { tempRange.first ?? 0 }
    var maxTemp: Int { tempRange.last ?? 30 }
    
    // Check if activity is available on a given day
    func isAvailableOnDay(_ dayName: String) -> Bool {
        return days.contains(dayName)
    }
}

// MARK: - Default Activities for New Users
extension Activity {
    static let defaultActivities: [Activity] = [
        Activity(
            name: "Morning Jog",
            location: "Central Park",
            tempRange: [10, 25],
            maxWind: 15,
            maxRain: 20,
            timeSlots: [TimeSlot(start: "06:00", end: "08:00")],
            days: ["Monday", "Wednesday", "Friday"]
        ),
        Activity(
            name: "Cycling",
            location: "Riverside Trail",
            tempRange: [15, 30],
            maxWind: 20,
            maxRain: 10,
            timeSlots: [TimeSlot(start: "16:00", end: "18:00")],
            days: ["Tuesday", "Thursday", "Saturday"]
        ),
        Activity(
            name: "Hiking",
            location: "Mountain Trail",
            tempRange: [5, 28],
            maxWind: 25,
            maxRain: 30,
            timeSlots: [TimeSlot(start: "08:00", end: "16:00")],
            days: ["Saturday", "Sunday"]
        ),
        Activity(
            name: "Tennis",
            location: "Local Tennis Court",
            tempRange: [18, 32],
            maxWind: 10,
            maxRain: 5,
            timeSlots: [TimeSlot(start: "09:00", end: "11:00"), TimeSlot(start: "17:00", end: "19:00")],
            days: ["Monday", "Wednesday", "Friday", "Sunday"]
        )
    ]
}
