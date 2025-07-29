import Foundation

struct TimeSlot: Codable, Identifiable {
    let id = UUID()
    let start: String // "09:00"
    let end: String   // "17:00"
    
    init(start: String, end: String) {
        self.start = start
        self.end = end
    }
    
    // Helper to check if current time falls within this slot
    func containsTime(_ time: String) -> Bool {
        return time >= start && time <= end
    }
}
