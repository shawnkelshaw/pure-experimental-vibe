import SwiftUI

struct RootTabView: View {
    @State private var selectedTab = 1 // Default to "My Garage" tab
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        Group {
            if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                // iPad: Use sidebar navigation
                NavigationSplitView {
                    SidebarView(selectedTab: $selectedTab)
                } detail: {
                    selectedContentView
                }
            } else {
                // iPhone: Use bottom tab navigation
                ZStack(alignment: .bottom) {
                    // Background for content to blur behind tab bar
                    Color.appBackground
                        .ignoresSafeArea(.all)
                    
                    // Main content area
                    TabView(selection: $selectedTab) {
                        // Tab 0: The Market
                        MarketView()
                            .tabItem { EmptyView() }
                            .tag(0)
                        
                        // Tab 1: My Garage (Default)
                        MyGarageView()
                            .tabItem { EmptyView() }
                            .tag(1)
                        
                        // Tab 2: More
                        MoreView()
                            .tabItem { EmptyView() }
                            .tag(2)
                    }
                    .tabViewStyle(.tabBarOnly)
                    
                    // Premium Glass Tab Bar with Enhanced Effects
                    VStack(spacing: 0) {
                        PremiumGlassTabBar(
                            selectedIndex: $selectedTab,
                            items: [
                                (icon: "chart.line.uptrend.xyaxis", title: "The Market"),
                                (icon: "car.fill", title: "My Garage"),
                                (icon: "ellipsis.circle", title: "More")
                            ]
                        )
                        .padding(.bottom, 28) // Account for home indicator
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    // MARK: - Computed Properties
    
    @ViewBuilder
    private var selectedContentView: some View {
        switch selectedTab {
        case 0:
            MarketView()
        case 1:
            MyGarageView()
        case 2:
            MoreView()
        default:
            MyGarageView()
        }
    }
}

// MARK: - Sidebar View for iPad
struct SidebarView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationStack {
            List {
                SidebarItem(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "The Market",
                    tag: 0,
                    selectedTab: $selectedTab
                )
                
                SidebarItem(
                    icon: "car.fill",
                    title: "My Garage",
                    tag: 1,
                    selectedTab: $selectedTab
                )
                
                SidebarItem(
                    icon: "ellipsis.circle",
                    title: "More",
                    tag: 2,
                    selectedTab: $selectedTab
                )
            }
            .navigationTitle("Vehicle Passports")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SidebarItem: View {
    let icon: String
    let title: String
    let tag: Int
    @Binding var selectedTab: Int
    
    var body: some View {
        Button(action: {
            selectedTab = tag
        }) {
            Label(title, systemImage: icon)
        }
        .listRowBackground(
            selectedTab == tag ? Color.accentColor.opacity(0.1) : Color.clear
        )
    }
}



struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        let authService = AuthService(isPreview: true)
        let themeManager = ThemeManager()
        
        Group {
            // iPhone SE - Default Dark Mode
            RootTabView()
                .environmentObject(authService)
                .environmentObject(NotificationService())
                .environmentObject(GarageViewModel(authService: authService))
                .environmentObject(themeManager)
                .previewDevice("iPhone SE (3rd generation)")
                .previewDisplayName("iPhone SE - Dark Mode Default")
                .preferredColorScheme(.dark)
            
            // iPhone 15 Pro - Default Dark Mode
            RootTabView()
                .environmentObject(authService)
                .environmentObject(NotificationService())
                .environmentObject(GarageViewModel(authService: authService))
                .environmentObject(themeManager)
                .previewDevice("iPhone 15 Pro")
                .previewDisplayName("iPhone 15 Pro - Dark Mode Default")
                .preferredColorScheme(.dark)
            
            // iPhone 15 Pro Max - Default Dark Mode
            RootTabView()
                .environmentObject(authService)
                .environmentObject(NotificationService())
                .environmentObject(GarageViewModel(authService: authService))
                .environmentObject(themeManager)
                .previewDevice("iPhone 15 Pro Max")
                .previewDisplayName("iPhone 15 Pro Max - Dark Mode Default")
                .preferredColorScheme(.dark)
            
            // iPad Preview - Default Dark Mode
            RootTabView()
                .environmentObject(authService)
                .environmentObject(NotificationService())
                .environmentObject(GarageViewModel(authService: authService))
                .environmentObject(themeManager)
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("iPad - Dark Mode Sidebar")
                .preferredColorScheme(.dark)
            
            // Light mode comparison
            RootTabView()
                .environmentObject(authService)
                .environmentObject(NotificationService())
                .environmentObject(GarageViewModel(authService: authService))
                .environmentObject(themeManager)
                .previewDevice("iPhone 15 Pro")
                .previewDisplayName("iPhone 15 Pro - Light Mode")
                .preferredColorScheme(.light)
        }
    }
} 