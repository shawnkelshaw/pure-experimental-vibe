import SwiftUI

struct RootTabView: View {
    @State private var selectedTab = 1 // Default to "My Garage" tab
    
    var body: some View {
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
            // Remove forced dark mode - let system handle theme
            
            // iOS 26 Native Liquid Glass Tab Bar
            VStack(spacing: 0) {
                // Tab Bar Container with iOS 26 Liquid Glass
                HStack(spacing: 0) {
                    // Market Tab
                    CustomTabBarButton(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "The Market",
                        isSelected: selectedTab == 0,
                        action: { selectedTab = 0 }
                    )
                    
                    // My Garage Tab
                    CustomTabBarButton(
                        icon: "car.fill",
                        title: "My Garage", 
                        isSelected: selectedTab == 1,
                        action: { selectedTab = 1 }
                    )
                    
                    // More Tab
                    CustomTabBarButton(
                        icon: "ellipsis.circle",
                        title: "More",
                        isSelected: selectedTab == 2,
                        action: { selectedTab = 2 }
                    )
                }
                .padding(.horizontal, 20)
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
        .frame(width: 402, height: 874)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct CustomTabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Icon with iOS 26 styling
                Image(systemName: icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? Color.tabBarSelectedText : Color.tabBarUnselectedText)
                    .frame(height: 24)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                // Text label with proper iOS 26 typography
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? Color.tabBarSelectedText : Color.tabBarUnselectedText)
                    .lineLimit(1)
                    .frame(height: 14)
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
            // Light mode preview
            RootTabView()
                .environmentObject(authService)
                .environmentObject(NotificationService())
                .environmentObject(GarageViewModel(authService: authService))
                .previewLayout(.fixed(width: 402, height: 874))
                .previewDisplayName("iOS 26 Tab Bar - Light Mode")
                .preferredColorScheme(.light)
            
            // Dark mode preview
            RootTabView()
                .environmentObject(authService)
                .environmentObject(NotificationService())
                .environmentObject(GarageViewModel(authService: authService))
                .previewLayout(.fixed(width: 402, height: 874))
                .previewDisplayName("iOS 26 Tab Bar - Dark Mode")
                .preferredColorScheme(.dark)
        }
    }
} 