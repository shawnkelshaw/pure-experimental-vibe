import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let themeManager = ThemeManager()
        
        Group {
            // iPhone Preview - Dark Mode Default
            ContentView()
                .environmentObject(AuthService(isPreview: true))
                .environmentObject(NotificationService())
                .environmentObject(themeManager)
                .previewDevice("iPhone 15 Pro")
                .previewDisplayName("iPhone 15 Pro - Dark Default")
                .preferredColorScheme(.dark)
            
            // iPad Preview - Dark Mode Default
            ContentView()
                .environmentObject(AuthService(isPreview: true))
                .environmentObject(NotificationService())
                .environmentObject(themeManager)
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("iPad Pro - Dark Default")
                .previewInterfaceOrientation(.portrait)
                .preferredColorScheme(.dark)
            
            // iPad Landscape Preview - Dark Mode Default
            ContentView()
                .environmentObject(AuthService(isPreview: true))
                .environmentObject(NotificationService())
                .environmentObject(themeManager)
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("iPad Pro Landscape - Dark Default")
                .previewInterfaceOrientation(.landscapeLeft)
                .preferredColorScheme(.dark)
        }
    }
} 