import Foundation

struct AppUser: Codable, Identifiable {
    let id: String // Firebase UID
    let email: String?
    let name: String?
    let createdAt: Date
    
    init(id: String, email: String? = nil, name: String? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.createdAt = Date()
    }
}
