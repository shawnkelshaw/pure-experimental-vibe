//
//  RootTabView.swift
//  The Vehicle Passport
//
//  Created by Shawn Kelshaw on August 2025.
//

// Reference: Docs/HIG_REFERENCE.md, Design/DESIGN_SYSTEM.md, Docs/GLASS_EFFECT_IMPLEMENTATION.md
// Constraints:
// - Use Apple-native SwiftUI controls (full library permitted)
// - Follow iOS 26 Human Interface Guidelines and visual system
// - Apply `.glassBackgroundEffect()` where appropriate
// - Avoid custom or third-party UI unless explicitly approved
// - Support portrait and landscape on iPhone and iPad
// - Use semantic spacing (see SystemSpacing.swift)

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
                // iPhone: Use native iOS 18 tab navigation with glass effects
                TabView(selection: $selectedTab) {
                    // Tab 0: The Market
                    MarketView()
                        .tabItem {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("The Market")
                        }
                        .tag(0)
                    
                    // Tab 1: My Garage (Default)
                    MyGarageView()
                        .tabItem {
                            Image(systemName: "car.fill")
                            Text("My Garage")
                        }
                        .tag(1)
                    
                    // Tab 2: More
                    MoreView()
                        .tabItem {
                            Image(systemName: "ellipsis.circle")
                            Text("More")
                        }
                        .tag(2)
                }
                .tint(Color.accentColor) // Use semantic accent color
                .toolbarBackground(.ultraThinMaterial, for: .tabBar) // iOS 18 glass effect
                .toolbarColorScheme(.dark, for: .tabBar) // Ensure proper contrast
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