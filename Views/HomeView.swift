import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: AuthService
    @State private var isLoading = true
    @State private var logoOpacity: Double = 0
    @State private var logoScale: Double = 0.8
    
    var body: some View {
        ZStack {
            // Content respecting safe areas (status bar will show)
            VStack(spacing: 0) {
                if isLoading {
                    // Loading screen with logo animation
                    VStack(spacing: 24) {
                        Spacer()
                        
                        // Logo container with dark theme
                        ZStack {
                            // Dark background with subtle border
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.cardBackground)
                                .frame(width: 120, height: 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.glassBorder, lineWidth: 2)
                                )
                            
                            // Logo placeholder
                            Image(systemName: "car.fill")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.textPrimary)
                        }
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        
                        // App name
                        Text("Vehicle Passports")
                            .font(.system(size: 28, weight: .ultraLight, design: .rounded))
                            .foregroundColor(.textPrimary)
                            .opacity(logoOpacity)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Show appropriate view based on authentication state
                    if authService.isAuthenticated {
                        RootTabView()
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                removal: .opacity.combined(with: .scale(scale: 1.05))
                            ))
                    } else {
                        AuthenticationView()
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity.combined(with: .move(edge: .bottom))
                            ))
                    }
                }
            }
        }
        .frame(width: 402, height: 874)
        // Remove forced dark mode - let system handle theme
        .onAppear {
            // Check real authentication state
            print("🔐 Checking real authentication state...")
            authService.checkAuthState()
            
            // Animate logo appearance
            withAnimation(.easeOut(duration: 1.0)) {
                logoOpacity = 1.0
                logoScale = 1.0
            }
            
            // Transition to main app after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func createTestUserForDemo() {
        // DISABLED - User wants real authentication only
        print("🔐 Test user creation disabled - using real Supabase authentication")
        return
    }

}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthService())
            .environmentObject(NotificationService())
            .previewLayout(.fixed(width: 402, height: 874))
            .previewDisplayName("Home View - Dark Theme")
    }
} 