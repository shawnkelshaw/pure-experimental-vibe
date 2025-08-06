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
            Homeview() // Temporarily changed from HomeView to WelcomeView
                .environmentObject(authService)
                .environmentObject(notificationService)
                .environmentObject(garageViewModel)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}

// Theme Management
class ThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme?
    
    @Published var displayMode: DisplayMode = .automatic {
        didSet {
            UserDefaults.standard.set(displayMode.rawValue, forKey: "displayMode")
            updateColorScheme()
        }
    }
    
    init() {
        // Load saved preferences
        if let savedMode = UserDefaults.standard.object(forKey: "displayMode") as? String {
            self.displayMode = DisplayMode(rawValue: savedMode) ?? .automatic
        }
        updateColorScheme()
    }
    
    private func updateColorScheme() {
        switch displayMode {
        case .automatic:
            colorScheme = nil // Use system setting
        case .light:
            colorScheme = .light
        case .dark:
            colorScheme = .dark
        }
    }
    
    func toggleMode() {
        switch displayMode {
        case .automatic:
            displayMode = .light
        case .light:
            displayMode = .dark
        case .dark:
            displayMode = .automatic
        }
    }
}

enum DisplayMode: String, CaseIterable {
    case automatic = "automatic"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .automatic: return "Automatic"
        case .light: return "Light Mode"
        case .dark: return "Dark Mode"
        }
    }
    
    var iconName: String {
        switch self {
        case .automatic: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
    
    var description: String {
        switch self {
        case .automatic: return "Follows system setting"
        case .light: return "Always light appearance"
        case .dark: return "Always dark appearance"
        }
    }
} 