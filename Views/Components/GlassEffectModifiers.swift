import SwiftUI

// MARK: - Color Extensions
extension Color {
    /// Glass border color that adapts to light/dark mode
    static let glassBorder = Color(.separator)
}

// MARK: - Glass Effect Modifiers

extension View {
    /// Applies a glass effect with blur, transparency, and borders
    func glassEffect(
        cornerRadius: CGFloat = 20,
        borderWidth: CGFloat = 1,
        material: Material = .ultraThinMaterial
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(material)
                    .overlay(
                        // Glass border with adaptive opacity
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.glassBorder, lineWidth: borderWidth)
                    )
                    .overlay(
                        // Subtle highlight for glass effect
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.1),
                                        Color.clear
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
    }
    
    /// Enhanced glass effect with multiple layers
    func liquidGlassEffect(
        cornerRadius: CGFloat = 20,
        borderWidth: CGFloat = 1.5,
        material: Material = .thinMaterial
    ) -> some View {
        self
            .background(
                ZStack {
                    // Base glass layer
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(material)
                    
                    // Inner shadow effect
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    Color.black.opacity(0.05)
                                ]),
                                center: .center,
                                startRadius: 1,
                                endRadius: cornerRadius * 2
                            )
                        )
                    
                    // Glass highlight
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.white.opacity(0.2), location: 0),
                                    .init(color: Color.white.opacity(0.05), location: 0.3),
                                    .init(color: Color.clear, location: 0.7),
                                    .init(color: Color.black.opacity(0.02), location: 1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Border with multiple layers
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.glassBorder, lineWidth: borderWidth)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.3),
                                            Color.clear,
                                            Color.black.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                }
            )
    }
    
    /// Ultra-thin glass effect for subtle elements
    func ultraThinGlass(
        cornerRadius: CGFloat = 12,
        borderWidth: CGFloat = 0.5
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.glassBorder.opacity(0.7), lineWidth: borderWidth)
                    )
                    .overlay(
                        // Subtle top highlight
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.08),
                                        Color.clear
                                    ]),
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    )
            )
    }
    
    /// Frosted glass effect with enhanced blur
    func frostGlassEffect(
        cornerRadius: CGFloat = 20,
        borderWidth: CGFloat = 1,
        intensity: Double = 0.8
    ) -> some View {
        self
            .background(
                ZStack {
                    // Primary frosted layer
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.thickMaterial)
                    
                    // Frosting overlay
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color(.systemBackground).opacity(intensity * 0.2))
                    
                    // Crystalline effect
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(intensity * 0.15),
                                    Color.clear,
                                    Color.glassBorder.opacity(intensity * 0.1)
                                ]),
                                center: UnitPoint(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: cornerRadius * 1.5
                            )
                        )
                    
                    // Enhanced border
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.glassBorder.opacity(intensity),
                                    Color.glassBorder.opacity(intensity * 0.5),
                                    Color.glassBorder.opacity(intensity)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: borderWidth
                        )
                }
            )
    }
}

// MARK: - Preset Glass Styles

struct GlassCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let material: Material
    
    init(
        cornerRadius: CGFloat = 20,
        material: Material = .ultraThinMaterial,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.material = material
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .liquidGlassEffect(cornerRadius: cornerRadius, material: material)
    }
}

struct GlassButton<Content: View>: View {
    let action: () -> Void
    let content: Content
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: action) {
            content
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .ultraThinGlass(cornerRadius: 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Glass Tab Bar Implementation

struct GlassTabBar: View {
    let items: [(icon: String, title: String)]
    @Binding var selectedIndex: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                GlassTabBarButton(
                    icon: item.icon,
                    title: item.title,
                    isSelected: selectedIndex == index,
                    action: { selectedIndex = index }
                )
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 16)
        .padding(.bottom, 32)
        .liquidGlassEffect(cornerRadius: 296, material: .ultraThinMaterial)
    }
}

struct GlassTabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 1) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color.accentColor : Color(.secondaryLabel))
                    .frame(height: 28)
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? Color.accentColor : Color(.secondaryLabel))
                    .frame(height: 12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            Group {
                if isSelected {
                    RoundedRectangle(cornerRadius: 100)
                        .frostGlassEffect(cornerRadius: 100, intensity: 0.6)
                }
            }
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}