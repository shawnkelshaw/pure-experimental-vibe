//
//  AuthenticationView.swift
//  The Vehicle Passport
//
//  Created by Shawn Kelshaw on August 2025.
//

// Reference: Docs/HIG_REFERENCE.md, Design/DESIGN_SYSTEM.md, Docs/GLASS_EFFECT_IMPLEMENTATION.md
// Constraints:
// - Use Apple-native SwiftUI controls (full library permitted)
// - Follow iOS 26 Human Interface Guidelines and visual system
// - Apply `.glassBackgroundEffect()` where appropriate
// - Avoid custom or third-party UI unless explicitly approved
// - Support portrait and landscape on iPhone and iPad
// - Use semantic spacing (see SystemSpacing.swift)

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
    
    // Focus management for keyboard
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case firstName, lastName, email, password, confirmPassword
    }
    
    // Form validation
    private var isFormValid: Bool {
        if isSignUpMode {
            return !email.isEmpty && 
                   !password.isEmpty && 
                   !firstName.isEmpty && 
                   !lastName.isEmpty && 
                   !confirmPassword.isEmpty &&
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
    
    var body: some View {
        ZStack {
            // Consistent adaptive background - full bleed
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: .extraLoose) {
                    // Header
                    VStack(spacing: .loose) {
                        Text("Vehicle Passport")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(isSignUpMode ? "Create Account" : "Sign In")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, .extraLoose)
                    
                    // Form
                    VStack(spacing: .loose) {
                        if isSignUpMode {
                            // First Name
                            VStack(alignment: .leading, spacing: .tight) {
                                Text("First Name")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("Enter first name", text: $firstName)
                                    .textFieldStyle(.roundedBorder)
                                    .focused($focusedField, equals: .firstName)
                                    .onSubmit {
                                        focusedField = .lastName
                                    }
                            }
                            
                            // Last Name
                            VStack(alignment: .leading, spacing: .tight) {
                                Text("Last Name")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("Enter last name", text: $lastName)
                                    .textFieldStyle(.roundedBorder)
                                    .focused($focusedField, equals: .lastName)
                                    .onSubmit {
                                        focusedField = .email
                                    }
                            }
                        }
                        
                        // Email
                        VStack(alignment: .leading, spacing: .tight) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter email", text: $email)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focused($focusedField, equals: .email)
                                .onSubmit {
                                    focusedField = .password
                                }
                        }
                        
                        // Password
                        VStack(alignment: .leading, spacing: .tight) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("Enter password", text: $password)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.password)
                                .focused($focusedField, equals: .password)
                                .onSubmit {
                                    if isSignUpMode {
                                        focusedField = .confirmPassword
                                    } else {
                                        focusedField = nil
                                    }
                                }
                        }
                        
                        if isSignUpMode {
                            // Confirm Password
                            VStack(alignment: .leading, spacing: .tight) {
                                Text("Confirm Password")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                SecureField("Confirm password", text: $confirmPassword)
                                    .textFieldStyle(.roundedBorder)
                                    .textContentType(.password)
                                    .focused($focusedField, equals: .confirmPassword)
                                    .onSubmit {
                                        focusedField = nil
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, .regular)
                    
                    // Action Buttons
                    VStack(spacing: .regular) {
                        Button(action: {
                            if isSignUpMode {
                                Task {
                                    await authService.signUp(email: email, password: password, firstName: firstName, lastName: lastName)
                                }
                            } else {
                                Task {
                                    await authService.signIn(email: email, password: password)
                                }
                            }
                        }) {
                            HStack {
                                if authService.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(isSignUpMode ? "Create Account" : "Sign In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, .regular)
                            .background(Color.accentColor)
                            .cornerRadius(.regular)
                        }
                        .disabled(!isFormValid || authService.isLoading)
                        .opacity((!isFormValid || authService.isLoading) ? 0.6 : 1.0)
                        
                        Button(action: {
                            isSignUpMode.toggle()
                            focusedField = isSignUpMode ? .firstName : .email
                        }) {
                            Text(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                        .disabled(authService.isLoading)
                        
                        if !isSignUpMode {
                            Button("Forgot Password?") {
                                showingPasswordReset = true
                            }
                            .foregroundColor(.secondary)
                            .buttonStyle(.plain)
                            .disabled(authService.isLoading)
                        }
                    }
                    .padding(.horizontal, .regular)
                    
                    Spacer(minLength: .extraLoose)
                }
            }
        }
        .onAppear {
            focusedField = isSignUpMode ? .firstName : .email
        }
        .onChange(of: isSignUpMode) { _, newValue in
            focusedField = newValue ? .firstName : .email
        }
        .sheet(isPresented: $showingPasswordReset) {
            PasswordResetView(resetEmail: $resetEmail, showingPasswordReset: $showingPasswordReset)
        }
    }
}

struct PasswordResetView: View {
    @Binding var resetEmail: String
    @Binding var showingPasswordReset: Bool
    @State private var message = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: .loose) {
                Text("Reset Password")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                TextField("Email", text: $resetEmail)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                Button("Send Reset Link") {
                    // TODO: Implement password reset
                    message = "Reset link sent to \(resetEmail)"
                }
                .buttonStyle(.borderedProminent)
                .disabled(resetEmail.isEmpty)
                
                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(.green)
                }
                
                Spacer()
            }
            .padding(.regular)
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingPasswordReset = false
                    }
                }
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthService())
}
