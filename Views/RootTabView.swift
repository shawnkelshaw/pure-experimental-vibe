import SwiftUI

struct RootTabView: View {
    @State private var selectedTab = 1
    @StateObject private var appointmentService = AppointmentService()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MarketView()
                .environmentObject(appointmentService)
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Market")
                }
                .tag(0)
            
            MyGarageView()
                .tabItem {
                    Image(systemName: "car.fill")
                    Text("My Garage")
                }
                .tag(1)
            
            MoreView()
                .environmentObject(appointmentService)
                .tabItem {
                    Image(systemName: "ellipsis.circle")
                    Text("More")
                }
                .badge(appointmentService.hasUpcomingAppointments ? "!" : nil)
                .tag(2)
        }
        .tint(.accentColor)
    }
}

struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        RootTabView()
            .environmentObject(AuthService(isPreview: true))
            .environmentObject(NotificationService())
            .environmentObject(GarageViewModel(authService: AuthService(isPreview: true)))
            .environmentObject(ThemeManager())
    }
}