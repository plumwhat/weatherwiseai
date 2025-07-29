import Foundation
import FirebaseAuth
import Combine

@MainActor
class AuthManager: ObservableObject {
    @Published var user: AppUser?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        listenToAuthState()
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    func listenToAuthState() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor in
                if let firebaseUser = firebaseUser {
                    self?.user = AppUser(
                        id: firebaseUser.uid,
                        email: firebaseUser.email,
                        name: firebaseUser.displayName
                    )
                } else {
                    self?.user = nil
                }
            }
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        
        do {
            // First, try to sign in
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("Sign in successful for user: \(result.user.uid)")
        } catch let error as NSError {
            // If user not found, create new account
            if error.code == AuthErrorCode.userNotFound.rawValue {
                await createAccount(email: email, password: password)
            } else {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    private func createAccount(email: String, password: String) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("Account created for user: \(result.user.uid)")
            
            // Create user document and add default activities
            await createUserWithDefaults(uid: result.user.uid, email: email)
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func createUserWithDefaults(uid: String, email: String) async {
        do {
            // Create user document
            let newUser = AppUser(id: uid, email: email)
            try await FirestoreService.shared.createUser(newUser)
            
            // Add default activities
            for activity in Activity.defaultActivities {
                try await FirestoreService.shared.addActivity(activity, for: uid)
            }
            
            print("User created with default activities")
        } catch {
            print("Error creating user with defaults: \(error)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
