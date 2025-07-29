import Foundation
import Combine

@MainActor
class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showingError = false
    
    private let authManager: AuthManager
    private var cancellables = Set<AnyCancellable>()
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        
        // Subscribe to auth manager state
        authManager.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        authManager.$errorMessage
            .sink { [weak self] errorMessage in
                if !errorMessage.isEmpty {
                    self?.errorMessage = errorMessage
                    self?.showingError = true
                }
            }
            .store(in: &cancellables)
    }
    
    var isFormValid: Bool {
        return !email.isEmpty && 
               !password.isEmpty && 
               email.contains("@") && 
               password.count >= 6
    }
    
    func signIn() {
        guard isFormValid else {
            errorMessage = "Please enter a valid email and password (minimum 6 characters)"
            showingError = true
            return
        }
        
        Task {
            await authManager.signIn(email: email, password: password)
        }
    }
    
    func clearError() {
        errorMessage = ""
        showingError = false
        authManager.errorMessage = ""
    }
    
    func resetForm() {
        email = ""
        password = ""
        clearError()
    }
}
