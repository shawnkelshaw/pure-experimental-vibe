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
                    
                    // iOS 26 Native Liquid Glass Tab Bar
                    AdaptiveTabBar(selectedTab: $selectedTab, horizontalSizeClass: horizontalSizeClass)
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

// MARK: - Adaptive Tab Bar
struct AdaptiveTabBar: View {
    @Binding var selectedTab: Int
    let horizontalSizeClass: UserInterfaceSizeClass?
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Bar Container with iOS 26 Liquid Glass
            HStack(spacing: 0) {
                // Market Tab
                CustomTabBarButton(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "The Market",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 },
                    sizeClass: horizontalSizeClass
                )
                
                // My Garage Tab
                CustomTabBarButton(
                    icon: "car.fill",
                    title: "My Garage", 
                    isSelected: selectedTab == 1,
                    action: { selectedTab = 1 },
                    sizeClass: horizontalSizeClass
                )
                
                // More Tab
                CustomTabBarButton(
                    icon: "ellipsis.circle",
                    title: "More",
                    isSelected: selectedTab == 2,
                    action: { selectedTab = 2 },
                    sizeClass: horizontalSizeClass
                )
            }
            .padding(.horizontal, horizontalSizeClass == .compact ? 20 : 32)
            .padding(.top, 12)
            .padding(.bottom, 28) // Account for home indicator
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.glassBorder.opacity(0.5), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
    }
}

struct CustomTabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    let sizeClass: UserInterfaceSizeClass?
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Icon with iOS 26 styling
                Image(systemName: icon)
                    .font(.system(size: sizeClass == .compact ? 18 : 20, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? Color.tabBarSelectedText : Color.tabBarUnselectedText)
                    .frame(height: sizeClass == .compact ? 24 : 28)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                // Text label with proper iOS 26 typography
                Text(title)
                    .font(.system(size: sizeClass == .compact ? 11 : 12, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? Color.tabBarSelectedText : Color.tabBarUnselectedText)
                    .lineLimit(1)
                    .frame(height: sizeClass == .compact ? 14 : 16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            Group {
                if isSelected {
                    // iOS 26 selected state background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.regularMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.tabBarSelectedText.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.tabBarSelectedText.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.tabBarSelectedText.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
        )
        .scaleEffect(isSelected ? 1.0 : 0.95)
        .animation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0), value: isSelected)
        .opacity(isSelected ? 1.0 : 0.8)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        let authService = AuthService(isPreview: true)
        
        Group {
            // iPhone Preview
            RootTabView()
                .environmentObject(authService)
                .environmentObject(NotificationService())
                .environmentObject(GarageViewModel(authService: authService))
                .previewDevice("iPhone 15 Pro")
                .previewDisplayName("iPhone - Light Mode")
                .preferredColorScheme(.light)
            
            // iPad Preview
            RootTabView()
                .environmentObject(authService)
                .environmentObject(NotificationService())
                .environmentObject(GarageViewModel(authService: authService))
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("iPad - Sidebar Navigation")
                .preferredColorScheme(.light)
            
            // Dark mode preview
            RootTabView()
                .environmentObject(authService)
                .environmentObject(NotificationService())
                .environmentObject(GarageViewModel(authService: authService))
                .previewDevice("iPhone 15 Pro")
                .previewDisplayName("iPhone - Dark Mode")
                .preferredColorScheme(.dark)
        }
    }
} 