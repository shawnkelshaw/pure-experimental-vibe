import Foundation
import SwiftUI
import Supabase

@MainActor
class AuthService: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseConfig.shared.client
    
    var isAuthenticated: Bool {
        user != nil
    }
    
    init(isPreview: Bool = false) {
        if isPreview {
            // Create mock user for previews
            self.user = User(
                id: UUID(),
                email: "preview@example.com",
                firstName: "Preview",
                lastName: "User",
                displayName: "Preview User",
                createdAt: Date()
            )
        } else {
            // Check for existing session
            checkAuthState()
        }
    }
    
    func checkAuthState() {
        print("🔐 Checking authentication state...")
        
        Task {
            do {
                let session = try await supabase.auth.session
                let authUser = session.user
                
                // Fetch user profile from database
                let response: [User] = try await supabase
                    .from("users")
                    .select()
                    .eq("id", value: authUser.id)
                    .execute()
                    .value
                
                await MainActor.run {
                    if let dbUser = response.first {
                        self.user = dbUser
                        print("✅ User authenticated: \(dbUser.email)")
                    }
                }
            } catch {
                print("❌ Auth check failed: \(error)")
            }
        }
    }
    
    func signUp(email: String, password: String, firstName: String, lastName: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Create Supabase user account
            let session = try await supabase.auth.signUp(email: email, password: password)
            let authUser = session.user
            
            // Create user profile in database
            let newUser = User(
                id: authUser.id,
                email: email,
                firstName: firstName,
                lastName: lastName,
                displayName: "\(firstName) \(lastName)",
                createdAt: Date()
            )
            
            // Insert user profile into database
            let response: [User] = try await supabase
                .from("users")
                .insert(newUser)
                .execute()
                .value
            
            await MainActor.run {
                if let dbUser = response.first {
                    self.user = dbUser
                    print("✅ Sign up successful: \(dbUser.email)")
                } else {
                    self.errorMessage = "Failed to create user profile"
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Sign up failed: \(error.localizedDescription)"
                self.isLoading = false
            }
            print("❌ Sign up error: \(error)")
        }
    }
    
    func signIn(email: String, password: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Sign in with Supabase
            let session = try await supabase.auth.signIn(email: email, password: password)
            
            // Fetch user profile from database
            let response: [User] = try await supabase
                .from("users")
                .select()
                .eq("id", value: session.user.id)
                .execute()
                .value
            
            await MainActor.run {
                if let dbUser = response.first {
                    self.user = dbUser
                    print("✅ Sign in successful: \(dbUser.email)")
                } else {
                    self.errorMessage = "User profile not found"
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Sign in failed: \(error.localizedDescription)"
                self.isLoading = false
            }
            print("❌ Sign in error: \(error)")
        }
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            await MainActor.run {
                self.user = nil
                print("✅ Sign out successful")
            }
        } catch {
            print("❌ Sign out error: \(error)")
            await MainActor.run {
                self.user = nil // Sign out locally even if remote fails
            }
        }
    }
}



