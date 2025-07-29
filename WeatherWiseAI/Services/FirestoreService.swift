import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - User Management
    
    func createUser(_ user: AppUser) async throws {
        try await db.collection("users").document(user.id).setData(from: user)
    }
    
    func getUser(uid: String) async throws -> AppUser? {
        let document = try await db.collection("users").document(uid).getDocument()
        return try document.data(as: AppUser.self)
    }
    
    // MARK: - Activity Management
    
    func fetchActivities(for userID: String) async throws -> [Activity] {
        let snapshot = try await db.collection("users")
            .document(userID)
            .collection("activities")
            .getDocuments()
        
        return try snapshot.documents.compactMap { document in
            try document.data(as: Activity.self)
        }
    }
    
    func addActivity(_ activity: Activity, for userID: String) async throws {
        try await db.collection("users")
            .document(userID)
            .collection("activities")
            .document(activity.id)
            .setData(from: activity)
    }
    
    func updateActivity(_ activity: Activity, for userID: String) async throws {
        var updatedActivity = activity
        // Update the updatedAt timestamp
        let updatedActivityData = try Firestore.Encoder().encode(updatedActivity)
        var data = updatedActivityData
        data["updatedAt"] = Timestamp()
        
        try await db.collection("users")
            .document(userID)
            .collection("activities")
            .document(activity.id)
            .setData(data, merge: true)
    }
    
    func deleteActivity(_ activityID: String, for userID: String) async throws {
        try await db.collection("users")
            .document(userID)
            .collection("activities")
            .document(activityID)
            .delete()
    }
    
    // MARK: - Batch Operations
    
    func addDefaultActivities(for userID: String) async throws {
        let batch = db.batch()
        let userRef = db.collection("users").document(userID)
        
        for activity in Activity.defaultActivities {
            let activityRef = userRef.collection("activities").document(activity.id)
            try batch.setData(from: activity, forDocument: activityRef)
        }
        
        try await batch.commit()
    }
    
    // MARK: - Real-time Listeners
    
    func listenToActivities(for userID: String, completion: @escaping ([Activity]) -> Void) -> ListenerRegistration {
        return db.collection("users")
            .document(userID)
            .collection("activities")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching activities: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }
                
                let activities = documents.compactMap { document in
                    try? document.data(as: Activity.self)
                }
                completion(activities)
            }
    }
}
