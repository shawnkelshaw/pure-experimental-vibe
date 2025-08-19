import Foundation
import SwiftUI

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = true
    @Published var useSystemTheme: Bool = false
    
    init() {
        // Initialize with dark mode as default
        self.isDarkMode = true
        self.useSystemTheme = false
    }
    
    func toggleMode() {
        if useSystemTheme {
            // If using system theme, switch to manual mode
            useSystemTheme = false
            isDarkMode.toggle()
        } else {
            // If manual mode, toggle between light and dark
            isDarkMode.toggle()
        }
    }
    
    func setSystemTheme() {
        useSystemTheme = true
    }
    
    func setLightMode() {
        useSystemTheme = false
        isDarkMode = false
    }
    
    func setDarkMode() {
        useSystemTheme = false
        isDarkMode = true
    }
    
    var currentColorScheme: ColorScheme? {
        if useSystemTheme {
            return nil // Use system default
        } else {
            return isDarkMode ? .dark : .light
        }
    }
}

