import SwiftUI

/// iOS 26 style tab bar that matches Apple's latest design language
/// Based on the design patterns from the iOS 26 Community Figma file
struct iOS26TabBar: View {
    @Binding var selectedIndex: Int
    let items: [(icon: String, title: String)]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                iOS26TabBarButton(
                    icon: item.icon,
                    title: item.title,
                    isSelected: selectedIndex == index,
                    action: { selectedIndex = index }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            // iOS 26 tab bar background with enhanced materials
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.appBackground.opacity(0.8))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.glassBorder.opacity(0.8),
                                    Color.glassBorder.opacity(0.2)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                )
                .shadow(color: .primary.opacity(0.08), radius: 16, x: 0, y: 8)
                .shadow(color: .primary.opacity(0.04), radius: 4, x: 0, y: 2)
        )
    }
}

struct iOS26TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                // Icon with iOS 26 styling
                ZStack {
                    if isSelected {
                        // Selected state background
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.tabBarSelectedText.opacity(0.12))
                            .frame(width: 44, height: 32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.tabBarSelectedText.opacity(0.2), lineWidth: 0.5)
                            )
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: isSelected ? .semibold : .medium, design: .rounded))
                        .foregroundColor(isSelected ? Color.tabBarSelectedText : Color.tabBarUnselectedText)
                        .scaleEffect(isSelected ? 1.0 : 0.9)
                        .symbolRenderingMode(.hierarchical)
                }
                .frame(height: 32)
                
                // Text label with iOS 26 typography
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? Color.tabBarSelectedText : Color.tabBarUnselectedText)
                    .lineLimit(1)
                    .frame(height: 12)
                    .opacity(isSelected ? 1.0 : 0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .opacity(isPressed ? 0.8 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Alternative Premium Tab Bar Style

struct PremiumGlassTabBar: View {
    @Binding var selectedIndex: Int
    let items: [(icon: String, title: String)]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                PremiumTabBarButton(
                    icon: item.icon,
                    title: item.title,
                    isSelected: selectedIndex == index,
                    action: { selectedIndex = index }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            ZStack {
                // Base material
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial)
                
                // Enhanced glass effect
                RoundedRectangle(cornerRadius: 32)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.primary.opacity(0.1), location: 0),
                                .init(color: Color.clear, location: 0.5),
                                .init(color: Color.primary.opacity(0.05), location: 1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Subtle border
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.glassBorder.opacity(0.6), lineWidth: 0.5)
                
                // Inner glow
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.primary.opacity(0.2),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .center
                        ),
                        lineWidth: 1
                    )
                    .blur(radius: 0.5)
            }
            .shadow(color: .primary.opacity(0.12), radius: 20, x: 0, y: 10)
            .shadow(color: .primary.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }
}

struct PremiumTabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        // Premium selected background
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.thinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.tabBarSelectedText.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.tabBarSelectedText.opacity(0.25), lineWidth: 1)
                            )
                            .frame(width: 48, height: 36)
                            .shadow(color: Color.tabBarSelectedText.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 19, weight: isSelected ? .semibold : .medium, design: .rounded))
                        .foregroundColor(isSelected ? Color.tabBarSelectedText : Color.tabBarUnselectedText)
                        .symbolRenderingMode(.hierarchical)
                        .scaleEffect(isSelected ? 1.05 : 0.95)
                }
                .frame(height: 36)
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? Color.tabBarSelectedText : Color.tabBarUnselectedText)
                    .lineLimit(1)
                    .opacity(isSelected ? 1.0 : 0.7)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
    }
}

// MARK: - Preview

struct iOS26TabBar_Previews: PreviewProvider {
    static var previews: some View {
        let items = [
            (icon: "chart.line.uptrend.xyaxis", title: "Market"),
            (icon: "car.fill", title: "Garage"),
            (icon: "ellipsis.circle", title: "More")
        ]
        
        VStack(spacing: 50) {
            Spacer()
            
            // Standard iOS 26 Tab Bar
            iOS26TabBar(
                selectedIndex: .constant(1),
                items: items
            )
            
            // Premium Glass Tab Bar
            PremiumGlassTabBar(
                selectedIndex: .constant(1),
                items: items
            )
            
            Spacer()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .previewDisplayName("iOS 26 Tab Bars")
    }
}