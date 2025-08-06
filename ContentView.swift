import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthService(isPreview: true))
            .environmentObject(NotificationService())
            .previewLayout(.fixed(width: 402, height: 874))
            .previewDisplayName("Vehicle Passport App")
    }
} 