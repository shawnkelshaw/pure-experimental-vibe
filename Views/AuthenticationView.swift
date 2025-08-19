//
//  AuthenticationView.swift
//  The Vehicle Passport
//
//  Created by Shawn Kelshaw on August 2025.
//

// Reference: Docs/HIG_REFERENCE.md, Design/DESIGN_SYSTEM.md, Docs/GLASS_EFFECT_IMPLEMENTATION.md
// Constraints:
// - Use only Apple-native SwiftUI controls (full library permitted)
// - Follow iOS 26 Human Interface Guidelines and layout behavior
// - Apply `.ultraThinGlass()` and custom effects as defined
// - Avoid third-party or custom UI unless explicitly approved
// - Support iPhone and iPad in both portrait and landscape
// - Use semantic spacing (SystemSpacing.swift)

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
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
            // Standard system background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: horizontalSizeClass == .regular ? .extraLoose : .loose) {
                    // Header
                    VStack(spacing: horizontalSizeClass == .regular ? .loose : .medium) {
                        Text("Vehicle Passport")
                            .font(horizontalSizeClass == .regular ? .largeTitle : .largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(isSignUpMode ? "Create Account" : "Sign In")
                            .font(horizontalSizeClass == .regular ? .title : .title2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, horizontalSizeClass == .regular ? .extraLoose : .loose)
                    
                    // Form Container with Glass Effect
                    VStack(spacing: horizontalSizeClass == .regular ? .loose : .medium) {
                        if isSignUpMode {
                            // First Name
                            VStack(alignment: .leading, spacing: .tight) {
                                Text("First Name")
                                    .font(horizontalSizeClass == .regular ? .title3 : .headline)
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
                                    .font(horizontalSizeClass == .regular ? .title3 : .headline)
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
                                .font(horizontalSizeClass == .regular ? .title3 : .headline)
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
                                .font(horizontalSizeClass == .regular ? .title3 : .headline)
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
                                    .font(horizontalSizeClass == .regular ? .title3 : .headline)
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
                    .padding(horizontalSizeClass == .regular ? .extraLoose : .regular)
                    .background(
                        Group {
                            RoundedRectangle(cornerRadius: horizontalSizeClass == .regular ? 20 : 16)
                                .fill(Color(.secondarySystemBackground))
                                .stroke(Color(.separator), lineWidth: 1)
                        }
                    )
                    .padding(.horizontal, horizontalSizeClass == .regular ? .extraLoose : .regular)
                    
                    // Action Buttons
                    VStack(spacing: horizontalSizeClass == .regular ? .medium : .regular) {
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
                                        .scaleEffect(horizontalSizeClass == .regular ? 1.0 : 0.8)
                                }
                                
                                Text(isSignUpMode ? "Create Account" : "Sign In")
                                    .font(horizontalSizeClass == .regular ? .title3 : .headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
                            .padding(.vertical, horizontalSizeClass == .regular ? .medium : .regular)
                            .background(
                                Group {
                                    Color.accentColor
                                }
                            )
                            .cornerRadius(horizontalSizeClass == .regular ? 16 : 12)
                        }
                        .disabled(!isFormValid || authService.isLoading)
                        .opacity((!isFormValid || authService.isLoading) ? 0.6 : 1.0)
                        
                        Button(action: {
                            isSignUpMode.toggle()
                            focusedField = isSignUpMode ? .firstName : .email
                        }) {
                            Text(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .foregroundColor(.accentColor)
                                .font(horizontalSizeClass == .regular ? .body : .callout)
                        }
                        .buttonStyle(.plain)
                        .disabled(authService.isLoading)
                        
                        if !isSignUpMode {
                            Button("Forgot Password?") {
                                showingPasswordReset = true
                            }
                            .foregroundColor(.secondary)
                            .buttonStyle(.plain)
                            .font(horizontalSizeClass == .regular ? .body : .callout)
                            .disabled(authService.isLoading)
                        }
                    }
                    .padding(.horizontal, horizontalSizeClass == .regular ? .extraLoose : .regular)
                    
                    Spacer(minLength: horizontalSizeClass == .regular ? .extraLoose : .loose)
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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var message = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: horizontalSizeClass == .regular ? .loose : .medium) {
                Text("Reset Password")
                    .font(horizontalSizeClass == .regular ? .largeTitle : .title)
                    .fontWeight(.bold)
                
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .font(horizontalSizeClass == .regular ? .body : .callout)
                
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
                        .foregroundColor(Color(.systemGreen))
                        .font(horizontalSizeClass == .regular ? .body : .callout)
                }
                
                Spacer()
            }
            .padding(horizontalSizeClass == .regular ? .extraLoose : .regular)
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
