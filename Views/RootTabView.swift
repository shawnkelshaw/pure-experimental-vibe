import SwiftUI

struct RootTabView: View {
    @State private var selectedTab = 1
    @EnvironmentObject var appointmentService: AppointmentService
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MarketView()
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
                .tabItem {
                    Image(systemName: "ellipsis.circle")
                    Text("More")
                }
                .badge(appointmentService.hasUpcomingAppointments ? "1" : nil)
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