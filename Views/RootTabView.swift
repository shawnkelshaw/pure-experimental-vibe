import SwiftUI

struct RootTabView: View {
    @State private var selectedTab = 1
    @EnvironmentObject var appointmentService: AppointmentService
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Market", systemImage: "chart.line.uptrend.xyaxis", value: 0) {
                MarketView()
            }
            
            Tab("My Garage", systemImage: "car.fill", value: 1) {
                MyGarageView()
            }
            
            Tab("More", systemImage: "ellipsis.circle", value: 2) {
                MoreView()
            }
            .badge(appointmentService.hasUpcomingAppointments ? 1 : 0)
        }
        .tint(.accentColor)
        .tabViewStyle(.sidebarAdaptable)
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