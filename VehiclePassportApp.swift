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
        // Load saved preferences
        if let savedMode = UserDefaults.standard.object(forKey: "displayMode") as? String {
            self.displayMode = DisplayMode(rawValue: savedMode) ?? .dark
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