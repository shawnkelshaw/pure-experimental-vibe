import SwiftUI

struct GlassEffectDemoView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Background with gradient for better glass visibility
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBlue).opacity(0.3),
                    Color(.systemPurple).opacity(0.3),
                    Color(.systemPink).opacity(0.3)
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
                        .foregroundColor(.primary)
                        .padding(.top)
                    
                    // Regular Glass Effect
                    VStack(spacing: 16) {
                        Text("Regular Glass Effect")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            Text("This is a regular glass card with blur and transparency")
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color(.systemYellow))
                                Text("Featured Content")
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding()
                        .glassEffect(cornerRadius: 16, material: .ultraThinMaterial)
                    }
                    
                    // Liquid Glass Effect
                    VStack(spacing: 16) {
                        Text("Liquid Glass Effect")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            Text("Enhanced glass with multiple layers and gradients")
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 20) {
                                VStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(Color(.systemRed))
                                    Text("Likes")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack {
                                    Image(systemName: "message.fill")
                                        .foregroundColor(Color(.systemBlue))
                                    Text("Messages")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack {
                                    Image(systemName: "share.fill")
                                        .foregroundColor(Color(.systemGreen))
                                    Text("Share")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
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
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            Button("Action 1") {}
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .ultraThinGlass()
                            
                            Button("Action 2") {}
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .ultraThinGlass()
                            
                            Button("Action 3") {}
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .ultraThinGlass()
                        }
                    }
                    
                    // Frost Glass Effect
                    VStack(spacing: 16) {
                        Text("Frost Glass Effect")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            Text("Crystalline frosted glass with enhanced blur")
                                .foregroundColor(.secondary)
                            
                            ProgressView(value: 0.7)
                                .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                            
                            Text("Loading... 70%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frostGlassEffect(cornerRadius: 16, intensity: 0.8)
                    }
                    
                    // Glass Card Component
                    VStack(spacing: 16) {
                        Text("Glass Card Component")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        GlassCard(cornerRadius: 24, material: .ultraThinMaterial) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "car.fill")
                                        .font(.title2)
                                        .foregroundColor(.accentColor)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Tesla Model 3")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text("Electric Vehicle")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
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
                                            .foregroundColor(.secondary)
                                        Text("350 mi")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading) {
                                        Text("Charge")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("85%")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading) {
                                        Text("Status")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
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
                            .foregroundColor(.primary)
                        
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