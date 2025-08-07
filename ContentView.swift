import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // iPhone Preview
            ContentView()
                .environmentObject(AuthService(isPreview: true))
                .environmentObject(NotificationService())
                .previewDevice("iPhone 15 Pro")
                .previewDisplayName("iPhone 15 Pro")
            
            // iPad Preview
            ContentView()
                .environmentObject(AuthService(isPreview: true))
                .environmentObject(NotificationService())
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("iPad Pro")
                .previewInterfaceOrientation(.portrait)
            
            // iPad Landscape Preview
            ContentView()
                .environmentObject(AuthService(isPreview: true))
                .environmentObject(NotificationService())
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("iPad Pro Landscape")
                .previewInterfaceOrientation(.landscapeLeft)
        }
    }
} 