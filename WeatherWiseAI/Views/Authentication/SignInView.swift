import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel: SignInViewModel
    @FocusState private var focusedField: Field?
    
    init() {
        // We'll inject the authManager in the init through environment
        self._viewModel = StateObject(wrappedValue: SignInViewModel(authManager: AuthManager()))
    }
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                // App Logo and Title
                VStack(spacing: 16) {
                    Image(systemName: "cloud.sun.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.accentColor)
                    
                    Text("WeatherWiseAI")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Smart weather recommendations for your activities")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Sign In Form
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        TextField("Email", text: $viewModel.email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .focused($focusedField, equals: .email)
                            .onSubmit {
                                focusedField = .password
                            }
                        
                        SecureField("Password", text: $viewModel.password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.password)
                            .focused($focusedField, equals: .password)
                            .onSubmit {
                                if viewModel.isFormValid {
                                    viewModel.signIn()
                                }
                            }
                    }
                    
                    Button(action: {
                        viewModel.signIn()
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            
                            Text(viewModel.isLoading ? "Signing In..." : "Sign In")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormValid ? Color.accentColor : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(Constants.UI.cornerRadius)
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                }
                .padding(.horizontal, 32)
                
                // Helper Text
                VStack(spacing: 8) {
                    Text("Don't have an account?")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text("We'll create one for you automatically")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
            .alert("Sign In Error", isPresented: $viewModel.showingError) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage)
            }
            .onAppear {
                // Update viewModel with the environment authManager
                viewModel.updateAuthManager(authManager)
            }
        }
    }
}

// MARK: - Preview
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AuthManager())
    }
}

// MARK: - SignInViewModel Extension
extension SignInViewModel {
    func updateAuthManager(_ authManager: AuthManager) {
        // This is a workaround for the environment object injection issue
        // In the actual implementation, consider using a different pattern
    }
}
