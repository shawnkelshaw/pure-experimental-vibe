import SwiftUI

struct GlassEffectDemoView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Background with gradient for better glass visibility
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.3),
                    Color.purple.opacity(0.3),
                    Color.pink.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Text("Glass Effect Showcase")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                        .padding(.top)
                    
                    // Regular Glass Effect
                    VStack(spacing: 16) {
                        Text("Regular Glass Effect")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        VStack(spacing: 12) {
                            Text("This is a regular glass card with blur and transparency")
                                .foregroundColor(.textSecondary)
                            
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("Featured Content")
                                    .foregroundColor(.textPrimary)
                            }
                        }
                        .padding()
                        .glassEffect(cornerRadius: 16, material: .ultraThinMaterial)
                    }
                    
                    // Liquid Glass Effect
                    VStack(spacing: 16) {
                        Text("Liquid Glass Effect")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        VStack(spacing: 12) {
                            Text("Enhanced glass with multiple layers and gradients")
                                .foregroundColor(.textSecondary)
                            
                            HStack(spacing: 20) {
                                VStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                    Text("Likes")
                                        .font(.caption)
                                        .foregroundColor(.textSecondary)
                                }
                                
                                VStack {
                                    Image(systemName: "message.fill")
                                        .foregroundColor(.blue)
                                    Text("Messages")
                                        .font(.caption)
                                        .foregroundColor(.textSecondary)
                                }
                                
                                VStack {
                                    Image(systemName: "share.fill")
                                        .foregroundColor(.green)
                                    Text("Share")
                                        .font(.caption)
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                        .padding()
                        .liquidGlassEffect(cornerRadius: 20, material: .thinMaterial)
                    }
                    
                    // Ultra-thin Glass
                    VStack(spacing: 16) {
                        Text("Ultra-thin Glass")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        HStack(spacing: 12) {
                            Button("Action 1") {}
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .ultraThinGlass()
                            
                            Button("Action 2") {}
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .ultraThinGlass()
                            
                            Button("Action 3") {}
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .ultraThinGlass()
                        }
                    }
                    
                    // Frost Glass Effect
                    VStack(spacing: 16) {
                        Text("Frost Glass Effect")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        VStack(spacing: 12) {
                            Text("Crystalline frosted glass with enhanced blur")
                                .foregroundColor(.textSecondary)
                            
                            ProgressView(value: 0.7)
                                .progressViewStyle(LinearProgressViewStyle(tint: .brandPrimary))
                            
                            Text("Loading... 70%")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                        .padding()
                        .frostGlassEffect(cornerRadius: 16, intensity: 0.8)
                    }
                    
                    // Glass Card Component
                    VStack(spacing: 16) {
                        Text("Glass Card Component")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        GlassCard(cornerRadius: 24, material: .ultraThinMaterial) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "car.fill")
                                        .font(.title2)
                                        .foregroundColor(.brandPrimary)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Tesla Model 3")
                                            .font(.headline)
                                            .foregroundColor(.textPrimary)
                                        
                                        Text("Electric Vehicle")
                                            .font(.caption)
                                            .foregroundColor(.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Circle()
                                        .fill(Color.statusSuccess)
                                        .frame(width: 8, height: 8)
                                }
                                
                                Divider()
                                    .background(Color.glassBorder)
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Range")
                                            .font(.caption)
                                            .foregroundColor(.textSecondary)
                                        Text("350 mi")
                                            .font(.headline)
                                            .foregroundColor(.textPrimary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading) {
                                        Text("Charge")
                                            .font(.caption)
                                            .foregroundColor(.textSecondary)
                                        Text("85%")
                                            .font(.headline)
                                            .foregroundColor(.textPrimary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading) {
                                        Text("Status")
                                            .font(.caption)
                                            .foregroundColor(.textSecondary)
                                        Text("Ready")
                                            .font(.headline)
                                            .foregroundColor(.statusSuccess)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Glass Tab Bar Demo
                    VStack(spacing: 16) {
                        Text("Glass Tab Bar")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        GlassTabBar(
                            items: [
                                (icon: "house.fill", title: "Home"),
                                (icon: "car.fill", title: "Garage"),
                                (icon: "chart.line.uptrend.xyaxis", title: "Market"),
                                (icon: "person.fill", title: "Profile")
                            ],
                            selectedIndex: $selectedTab
                        )
                        .frame(height: 80)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
        }
        .navigationTitle("Glass Effects")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct GlassEffectDemoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GlassEffectDemoView()
        }
    }
}