import Foundation
import Supabase
import SwiftUI

@MainActor
class AuthService: ObservableObject {
    @Published var user: User? = nil
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let supabase = SupabaseConfig.shared.client
    
    init() {
        checkAuthState()
        setupAuthListener()
    }
    
    // Preview-safe initializer
    init(isPreview: Bool) {
        if !isPreview {
            checkAuthState()
            setupAuthListener()
        }
    }
    
    // MARK: - Authentication State
    
    func checkAuthState() {
        Task {
            do {
                print("🔍 Checking auth state...")
                let session = try await supabase.auth.session
                print("✅ Session check completed")
                await updateAuthState(with: session)
            } catch {
                print("❌ Auth check error: \(error)")
                await updateAuthState(with: nil)
            }
        }
    }
    
    private func setupAuthListener() {
        Task {
            for await state in supabase.auth.authStateChanges {
                await updateAuthState(with: state.session)
            }
        }
    }
    
    private func updateAuthState(with session: Session?) async {
        if let session = session {
            // Fetch user profile FIRST, then set authenticated
            await fetchUserProfile(userId: session.user.id)
            isAuthenticated = true
        } else {
            isAuthenticated = false
            user = nil
        }
        
        // Clear any existing error messages when auth state changes
        errorMessage = nil
    }
    
    // MARK: - Sign Up
    
    func signUp(email: String, password: String, firstName: String? = nil, lastName: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔐 Starting sign up for email: \(email)")
            let authResponse = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            print("✅ Auth sign up successful for user: \(authResponse.user.id)")
            
            // Create user profile
            await createUserProfile(
                userId: authResponse.user.id,
                email: email,
                firstName: firstName,
                lastName: lastName
            )
            
            // Get the session and update auth state
            if let session = authResponse.session {
                print("✅ Session found, updating auth state")
                await updateAuthState(with: session)
            } else {
                print("⚠️ No session in auth response - email confirmation may be required")
            }
            
            isLoading = false
        } catch {
            print("❌ Sign up error: \(error)")
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    // MARK: - Sign In
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔐 Starting sign in for email: \(email)")
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            print("✅ Sign in successful")
            await updateAuthState(with: session)
            isLoading = false
        } catch {
            print("❌ Sign in error: \(error)")
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() async {
        print("🚪 Starting sign out process...")
        do {
            try await supabase.auth.signOut()
            print("✅ Supabase sign out successful")
            user = nil
            isAuthenticated = false
            print("✅ Auth state cleared - isAuthenticated: \(isAuthenticated)")
        } catch {
            print("❌ Sign out error: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - User Profile Management
    
    private func createUserProfile(userId: UUID, email: String, firstName: String?, lastName: String?) async {
        do {
            print("👤 Creating user profile for: \(email)")
            let userProfile = User(
                id: userId,
                email: email,
                firstName: firstName,
                lastName: lastName,
                displayName: nil, // User can set this later in profile
                phoneNumber: nil,
                streetAddress: nil,
                city: nil,
                stateProvince: nil,
                postalCode: nil,
                country: nil,
                avatarUrl: nil,
                notificationsEmail: true,
                notificationsPush: true,
                notificationsBluetooth: true,
                notificationsMarketing: false,
                isActive: true,
                lastLoginAt: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            try await supabase
                .from("users")
                .insert(userProfile)
                .execute()
                
            print("✅ User profile created successfully")
            
            // Set the user immediately instead of fetching again
            user = userProfile
            print("✅ User set directly: \(userProfile.preferredDisplayName)")
            
        } catch {
            print("❌ Error creating user profile: \(error)")
            print("❌ Full error details: \(error.localizedDescription)")
            
            // If profile creation fails, create a basic user object from auth data
            let basicUser = User(
                id: userId,
                email: email,
                firstName: firstName,
                lastName: lastName,
                displayName: nil,
                phoneNumber: nil,
                streetAddress: nil,
                city: nil,
                stateProvince: nil,
                postalCode: nil,
                country: nil,
                avatarUrl: nil,
                notificationsEmail: true,
                notificationsPush: true,
                notificationsBluetooth: true,
                notificationsMarketing: false,
                isActive: true,
                lastLoginAt: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
            user = basicUser
            print("🔧 Set basic user profile as fallback")
        }
    }
    
    private func fetchUserProfile(userId: UUID) async {
        print("🔍 Fetching user profile for ID: \(userId)")
        print("🔍 UUID string: \(userId.uuidString)")
        
        do {
            let response: [User] = try await supabase
                .from("users")
                .select()
                .eq("id", value: userId.uuidString)
                .execute()
                .value
            
            print("✅ Supabase call succeeded - found \(response.count) users")
            
            if let fetchedUser = response.first {
                user = fetchedUser
                print("✅ User profile loaded: \(fetchedUser.preferredDisplayName)")
            } else {
                print("❌ User exists in auth but NOT in users table - this is the problem")
                print("❌ Need to check your Supabase users table")
            }
        } catch {
            print("❌ Supabase call FAILED: \(error)")
            print("❌ Error type: \(type(of: error))")
            print("❌ Error description: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Profile Management
    
    func updateUserProfile(_ updatedUser: User) async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("👤 Updating user profile for: \(updatedUser.email)")
            let response: [User] = try await supabase
                .from("users")
                .update(updatedUser)
                .eq("id", value: updatedUser.id.uuidString)
                .select()
                .execute()
                .value
            
            if let updatedProfile = response.first {
                user = updatedProfile
                print("✅ User profile updated: \(updatedProfile.preferredDisplayName)")
            }
            
            isLoading = false
        } catch {
            print("❌ Profile update error: \(error)")
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func updateLastLogin() async {
        guard let currentUser = user else { return }
        
        do {
            try await supabase
                .from("users")
                .update(["last_login_at": Date().ISO8601Format()])
                .eq("id", value: currentUser.id.uuidString)
                .execute()
            
            print("✅ Last login time updated")
        } catch {
            print("❌ Failed to update last login: \(error)")
        }
    }
    
    // MARK: - Password Reset
    
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
} 