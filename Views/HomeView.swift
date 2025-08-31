//
//  HomeView.swift
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

struct HomeView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var garageViewModel: GarageViewModel
    @EnvironmentObject var appointmentService: AppointmentService
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isLoading = true
    @State private var logoOpacity: Double = 0
    @State private var logoScale: Double = 0.8
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if isLoading {
                    // Loading screen with logo animation
                    VStack(spacing: horizontalSizeClass == .regular ? 32 : 24) {
                        Spacer()
                        
                        // Logo container with glass effect
                        ZStack {
                            // Glass background effect
                            Group {
                                RoundedRectangle(cornerRadius: horizontalSizeClass == .regular ? 32 : 24)
                                    .fill(Color(.secondarySystemBackground))
                                    .stroke(Color(.separator), lineWidth: 1)
                            }
                            .frame(
                                width: horizontalSizeClass == .regular ? 160 : 120,
                                height: horizontalSizeClass == .regular ? 160 : 120
                            )
                            
                            // Logo placeholder
                            Image(systemName: "car.fill")
                                .font(.system(
                                    size: horizontalSizeClass == .regular ? 64 : 48,
                                    weight: .light
                                ))
                                .foregroundColor(.primary)
                        }
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        
                        // App name
                        Text("Vehicle Passports")
                            .font(.system(
                                size: horizontalSizeClass == .regular ? 36 : 28,
                                weight: .ultraLight,
                                design: .rounded
                            ))
                            .foregroundColor(.primary)
                            .opacity(logoOpacity)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Show appropriate view based on authentication state
                    if authService.isAuthenticated {
                        RootTabView()
                            .environmentObject(garageViewModel)
                            .environmentObject(appointmentService)
                            .onAppear {
                                // Clear appointments when user signs in
                                appointmentService.clearAllAppointments()
                            }
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let authService = AuthService(isPreview: true)
        let themeManager = ThemeManager()
        
        Group {
            // iPhone Preview - Dark Mode
            HomeView()
                .environmentObject(authService)
                .environmentObject(NotificationService())
                .environmentObject(GarageViewModel(authService: authService))
                .environmentObject(themeManager)
                .previewDevice("iPhone 15 Pro")
                .previewDisplayName("iPhone - Home View - Dark Mode")
                .preferredColorScheme(.dark)
            
            // iPhone Preview - Light Mode
            HomeView()
                .environmentObject(authService)
                .environmentObject(NotificationService())
                .environmentObject(GarageViewModel(authService: authService))
                .environmentObject(themeManager)
                .previewDevice("iPhone 15 Pro")
                .previewDisplayName("iPhone - Home View - Light Mode")
                .preferredColorScheme(.light)
            
            // iPad Preview - Dark Mode
            HomeView()
                .environmentObject(authService)
                .environmentObject(NotificationService())
                .environmentObject(GarageViewModel(authService: authService))
                .environmentObject(themeManager)
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("iPad - Home View - Dark Mode")
                .preferredColorScheme(.dark)
            
            // iPad Preview - Light Mode
            HomeView()
                .environmentObject(authService)
                .environmentObject(NotificationService())
                .environmentObject(GarageViewModel(authService: authService))
                .environmentObject(themeManager)
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("iPad - Home View - Light Mode")
                .preferredColorScheme(.light)
        }
    }
} 