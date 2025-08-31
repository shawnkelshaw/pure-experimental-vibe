import SwiftUI

struct RootTabView: View {
    @State private var selectedTab = 1
    @EnvironmentObject var appointmentService: AppointmentService
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack(spacing: 0) {
            // Status bar spacer for iPad
            if horizontalSizeClass == .regular {
                Color.clear
                    .frame(height: 44)
            }
            
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
            .tabViewStyle(.automatic)
        }
        .ignoresSafeArea(.container, edges: horizontalSizeClass == .regular ? [] : .all)
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