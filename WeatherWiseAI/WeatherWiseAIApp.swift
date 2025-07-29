import SwiftUI
import Firebase

@main
struct WeatherWiseAIApp: App {
    @StateObject private var authManager = AuthManager()
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Group {
            if authManager.user != nil {
                DashboardView()
            } else {
                SignInView()
            }
        }
        .onAppear {
            authManager.listenToAuthState()
        }
    }
}
