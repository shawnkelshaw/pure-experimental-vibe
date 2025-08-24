//
//  VehiclePassportApp.swift
//  The Vehicle Passport
//
//  Created by Shawn Kelshaw on August 2025.
//

// Reference: Docs/HIG_REFERENCE.md, Design/DESIGN_SYSTEM.md, Docs/GLASS_EFFECT_IMPLEMENTATION.md
// Constraints:
// - Use only Apple-native SwiftUI controls (full library permitted)
// - Follow iOS 26 Human Interface Guidelines and layout behavior
// - Apply `.glassBackgroundEffect()` and custom effects as defined
// - Avoid third-party or custom UI unless explicitly approved
// - Support iPhone and iPad in both portrait and landscape
// - Use semantic spacing (SystemSpacing.swift)

import SwiftUI

@main
struct VehiclePassportApp: App {
    // MARK: - Environment Objects
    @StateObject private var authService = AuthService()
    @StateObject private var notificationService = NotificationService()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var garageViewModel = GarageViewModel(authService: AuthService())
    @StateObject private var appointmentService = AppointmentService()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(authService)
                .environmentObject(notificationService)
                .environmentObject(garageViewModel)
                .environmentObject(themeManager)
                .environmentObject(appointmentService)
                .preferredColorScheme(themeManager.currentColorScheme)
        }
    }
}

