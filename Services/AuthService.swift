import Foundation
import SwiftUI
import Supabase

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
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            // Create mock user for demo
            self.user = User(
                id: UUID(),
                email: email,
                firstName: firstName,
                lastName: lastName,
                displayName: "\(firstName) \(lastName)",
                createdAt: Date()
            )
            self.isLoading = false
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



