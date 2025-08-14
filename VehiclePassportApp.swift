import SwiftUI

@main
struct VehiclePassportApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var notificationService = NotificationService()
    @StateObject private var garageViewModel: GarageViewModel
    @StateObject private var themeManager = ThemeManager()
    
    init() {
        let auth = AuthService()
        _authService = StateObject(wrappedValue: auth)
        _notificationService = StateObject(wrappedValue: NotificationService())
        _garageViewModel = StateObject(wrappedValue: GarageViewModel(authService: auth))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(notificationService)
                .environmentObject(garageViewModel)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
                // Enable all device orientations for proper adaptivity
                .onAppear {
                    // This allows the app to rotate on all devices
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                }
        }
        // Support all orientations on iPad, portrait on iPhone
        .windowResizability(.contentSize)
    }
}

// Theme Management
class ThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme?
    
    @Published var displayMode: DisplayMode = .dark {
        didSet {
            UserDefaults.standard.set(displayMode.rawValue, forKey: "displayMode")
            updateColorScheme()
        }
    }
    
    init() {
        // TEMPORARY: Clear any cached automatic mode preference
        if let savedMode = UserDefaults.standard.object(forKey: "displayMode") as? String,
           savedMode == "automatic" {
            UserDefaults.standard.removeObject(forKey: "displayMode")
        }
        
        // Always start with dark mode as default
        self.displayMode = .dark
        
        // Load saved preferences only if they exist and are valid
        if let savedMode = UserDefaults.standard.object(forKey: "displayMode") as? String,
           let mode = DisplayMode(rawValue: savedMode) {
            self.displayMode = mode
        } else {
            // Ensure dark mode is set as default
            self.displayMode = .dark
        }
        updateColorScheme()
    }
    
    private func updateColorScheme() {
        switch displayMode {
        case .light:
            colorScheme = .light
        case .dark:
            colorScheme = .dark
        }
    }
    
    func toggleMode() {
        switch displayMode {
        case .light:
            displayMode = .dark
        case .dark:
            displayMode = .light
        }
    }
    
    /// Reset to dark mode default (useful for debugging)
    func resetToDefault() {
        UserDefaults.standard.removeObject(forKey: "displayMode")
        displayMode = .dark
        updateColorScheme()
    }
}

enum DisplayMode: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .light: return "Light Mode"
        case .dark: return "Dark Mode"
        }
    }
    
    var iconName: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
    
    var description: String {
        switch self {
        case .light: return "Always light appearance"
        case .dark: return "Always dark appearance"
        }
    }
} 