import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authService: AuthService
    @State private var isSignUpMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var showingPasswordReset = false
    @State private var resetEmail = ""
    
    var body: some View {
        ZStack {
            // Consistent adaptive background - full bleed
            Color.appBackground
                .ignoresSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer(minLength: 60)
                    
                    // Logo and Title Section
                    VStack(spacing: 24) {
                        // Logo
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.cardBackground)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.glassBorder, lineWidth: 2)
                                )
                            
                            Image(systemName: "car.fill")
                                .font(.system(size: 32, weight: .light))
                                .foregroundColor(.textPrimary)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Vehicle Passport")
                                .font(.system(size: 28, weight: .ultraLight, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text(isSignUpMode ? "Create Account" : "Welcome Back")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Authentication Form
                    VStack(spacing: 20) {
                        // Sign Up Only Fields
                        if isSignUpMode {
                            HStack(spacing: 12) {
                                AuthTextField(
                                    text: $firstName,
                                    placeholder: "First Name",
                                    icon: "person"
                                )
                                
                                AuthTextField(
                                    text: $lastName,
                                    placeholder: "Last Name",
                                    icon: "person.fill"
                                )
                            }
                        }
                        
                        // Email Field
                        AuthTextField(
                            text: $email,
                            placeholder: "Email",
                            icon: "envelope",
                            keyboardType: .emailAddress,
                            textContentType: .emailAddress
                        )
                        
                        // Password Field
                        AuthTextField(
                            text: $password,
                            placeholder: "Password",
                            icon: "lock",
                            isSecure: true
                        )
                        
                        // Confirm Password (Sign Up Only)
                        if isSignUpMode {
                            AuthTextField(
                                text: $confirmPassword,
                                placeholder: "Confirm Password",
                                icon: "lock.fill",
                                isSecure: true
                            )
                        }
                        
                        // Action Buttons
                        VStack(spacing: 16) {
                            // Primary Action Button
                            Button(action: {
                                Task {
                                    if isSignUpMode {
                                        await handleSignUp()
                                    } else {
                                        await handleSignIn()
                                    }
                                }
                            }) {
                                HStack {
                                    if authService.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                                            .scaleEffect(0.8)
                                    }
                                    
                                    Text(isSignUpMode ? "Create Account" : "Sign In")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.accentColor)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.accentColor, lineWidth: 1)
                                        )
                                )
                            }
                            .disabled(authService.isLoading || !isFormValid)
                            .opacity(authService.isLoading || !isFormValid ? 0.6 : 1.0)
                            
                            // Toggle Mode Button
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isSignUpMode.toggle()
                                    clearForm()
                                }
                            }) {
                                                            Text(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(.link))
                            }
                            
                            // Forgot Password (Sign In Only)
                            if !isSignUpMode {
                                Button(action: {
                                    showingPasswordReset = true
                                }) {
                                                                    Text("Forgot Password?")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(.link))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    // Remove forced color scheme - let system handle theme adaptation
        .alert("Error", isPresented: .constant(authService.errorMessage != nil)) {
            Button("OK") {
                authService.errorMessage = nil
            }
        } message: {
            if let errorMessage = authService.errorMessage {
                Text(errorMessage)
            }
        }
        .sheet(isPresented: $showingPasswordReset) {
            PasswordResetView(resetEmail: $resetEmail)
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        if isSignUpMode {
            return !email.isEmpty &&
                   !password.isEmpty &&
                   !confirmPassword.isEmpty &&
                   !firstName.isEmpty &&
                   password == confirmPassword &&
                   password.count >= 6 &&
                   email.contains("@")
        } else {
            return !email.isEmpty &&
                   !password.isEmpty &&
                   password.count >= 6 &&
                   email.contains("@")
        }
    }
    
    // MARK: - Actions
    
    private func handleSignUp() async {
        guard password == confirmPassword else {
            authService.errorMessage = "Passwords do not match"
            return
        }
        
        await authService.signUp(
            email: email,
            password: password,
            firstName: firstName.isEmpty ? nil : firstName,
            lastName: lastName.isEmpty ? nil : lastName
        )
    }
    
    private func handleSignIn() async {
        await authService.signIn(email: email, password: password)
    }
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        firstName = ""
        lastName = ""
    }
}

// MARK: - Auth Text Field

struct AuthTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var isSecure: Bool = false
    
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(.secondaryLabel))
                .frame(width: 20)
            
            Group {
                if isSecure && !isPasswordVisible {
                    SecureField(placeholder, text: $text)
                        .textContentType(nil) // DISABLE AUTO PASSWORD
                } else {
                    TextField(placeholder, text: $text)
                        .textContentType(textContentType)
                }
            }
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(Color(.label))
            
            // Password visibility toggle button (only show for secure fields)
            if isSecure {
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(.secondaryLabel))
                        .frame(width: 20)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.separator), lineWidth: 1)
                )
        )
    }
}

// MARK: - Password Reset View

struct PasswordResetView: View {
    @EnvironmentObject var authService: AuthService
    @Binding var resetEmail: String
    @Environment(\.dismiss) private var dismiss
    @State private var emailSent = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    if emailSent {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.green)
                            
                            Text("Reset Email Sent")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.primary)
                            
                            Text("Check your email for password reset instructions.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        VStack(spacing: 20) {
                            Text("Reset Password")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(.primary)
                            
                            Text("Enter your email address and we'll send you instructions to reset your password.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            AuthTextField(
                                text: $resetEmail,
                                placeholder: "Email",
                                icon: "envelope",
                                keyboardType: .emailAddress
                            )
                            
                            Button(action: {
                                Task {
                                    await authService.resetPassword(email: resetEmail)
                                    if authService.errorMessage == nil {
                                        emailSent = true
                                    }
                                }
                            }) {
                                HStack {
                                    if authService.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                                            .scaleEffect(0.8)
                                    }
                                    
                                    Text("Send Reset Email")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.background)
                                )
                            }
                            .disabled(authService.isLoading || resetEmail.isEmpty || !resetEmail.contains("@"))
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Password Reset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
                    // Remove forced color scheme - let system handle theme adaptation
        .alert("Error", isPresented: .constant(authService.errorMessage != nil)) {
            Button("OK") {
                authService.errorMessage = nil
            }
        } message: {
            if let errorMessage = authService.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

// MARK: - Previews

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // iPhone Preview
            AuthenticationView()
                .environmentObject(AuthService(isPreview: true))
                .previewDevice("iPhone 15 Pro")
                .previewDisplayName("iPhone - Authentication")
            
            // iPad Preview
            AuthenticationView()
                .environmentObject(AuthService(isPreview: true))
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("iPad - Authentication")
        }
    }
} 