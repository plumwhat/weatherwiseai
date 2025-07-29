import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel: DashboardViewModel
    @StateObject private var activitiesViewModel: MyActivitiesViewModel
    @State private var selectedTab = 0
    
    init() {
        // Note: In actual implementation, inject dependencies properly
        let authManager = AuthManager()
        self._viewModel = StateObject(wrappedValue: DashboardViewModel(authManager: authManager))
        self._activitiesViewModel = StateObject(wrappedValue: MyActivitiesViewModel(authManager: authManager))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Forecast Tab
            NavigationView {
                ForecastView()
                    .environmentObject(viewModel)
                    .navigationTitle("Weather Forecast")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            ProfileMenuButton()
                                .environmentObject(authManager)
                        }
                    }
            }
            .tabItem {
                Image(systemName: "cloud.sun.fill")
                Text("Forecast")
            }
            .tag(0)
            
            // My Activities Tab
            NavigationView {
                MyActivitiesView()
                    .environmentObject(activitiesViewModel)
                    .navigationTitle("My Activities")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            ProfileMenuButton()
                                .environmentObject(authManager)
                        }
                    }
            }
            .tabItem {
                Image(systemName: "figure.outdoor.cycle")
                Text("Activities")
            }
            .tag(1)
        }
        .accentColor(.accentColor)
        .onAppear {
            // Update view models with environment auth manager
            viewModel.updateAuthManager(authManager)
            activitiesViewModel.updateAuthManager(authManager)
        }
    }
}

struct ProfileMenuButton: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showingProfileMenu = false
    
    var body: some View {
        Button(action: {
            showingProfileMenu = true
        }) {
            Image(systemName: "person.circle.fill")
                .font(.title2)
        }
        .confirmationDialog("Profile", isPresented: $showingProfileMenu) {
            Button("Sign Out", role: .destructive) {
                authManager.signOut()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            if let user = authManager.user {
                Text("Signed in as \(user.email ?? "Unknown")")
            }
        }
    }
}

// MARK: - Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(AuthManager())
    }
}

// MARK: - ViewModel Extensions
extension DashboardViewModel {
    func updateAuthManager(_ authManager: AuthManager) {
        // Workaround for dependency injection
    }
}

extension MyActivitiesViewModel {
    func updateAuthManager(_ authManager: AuthManager) {
        // Workaround for dependency injection
    }
}
