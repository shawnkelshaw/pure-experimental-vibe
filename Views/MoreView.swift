//
//  MoreView.swift
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

struct MoreView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingProfile = false
    @State private var showingSettings = false
    
    private var memberSinceYear: String {
        guard let user = authService.user else { return "2024" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: user.createdAt)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: .loose) {
                    // Profile Section
                    VStack(spacing: .regular) {
                        HStack {
                            Text("Profile")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Profile Card
                        VStack(spacing: .regular) {
                            HStack(spacing: .regular) {
                                // Profile Avatar
                                Image(systemName: "person.fill")
                                    .font(.system(size: 28, weight: .light))
                                    .foregroundColor(.primary)
                                    .frame(width: 60, height: 60)
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.glassBorder, lineWidth: 1)
                                            )
                                    )
                                
                                VStack(alignment: .leading, spacing: .extraTight) {
                                    Text(authService.user?.preferredDisplayName ?? "User")
                                        .font(.system(size: 20, weight: .medium, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Text(authService.user?.email ?? "user@example.com")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.secondary)
                                    
                                    Text("Member since \(memberSinceYear)")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: { showingProfile.toggle() }) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.glassBorder, lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // Appearance Section
                    VStack(spacing: .regular) {
                        HStack {
                            Text("Appearance")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Theme Card
                        VStack(spacing: .regular) {
                            HStack(spacing: .regular) {
                                // Theme Icon
                                Image(systemName: "paintbrush.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.primary)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.glassBorder, lineWidth: 1)
                                            )
                                    )
                                
                                VStack(alignment: .leading, spacing: .extraTight) {
                                    Text("Theme")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Text("Follows system setting")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: { showingSettings.toggle() }) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.glassBorder, lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // Settings Section
                    VStack(spacing: .regular) {
                        HStack {
                            Text("Settings")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Settings Items
                        VStack(spacing: 0) { // Keep 0 for seamless list items
                            SettingsRow(
                                icon: "bell.fill",
                                title: "Notifications",
                                subtitle: "Manage your alerts",
                                action: { /* Handle notifications */ }
                            )
                            
                            SettingsRow(
                                icon: "lock.fill",
                                title: "Privacy",
                                subtitle: "Control your data",
                                action: { /* Handle privacy */ }
                            )
                            
                            SettingsRow(
                                icon: "questionmark.circle.fill",
                                title: "Help & Support",
                                subtitle: "Get assistance",
                                action: { /* Handle help */ }
                            )
                            
                            SettingsRow(
                                icon: "info.circle.fill",
                                title: "About",
                                subtitle: "App version and info",
                                action: { /* Handle about */ }
                            )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.glassBorder, lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // Account Section
                    VStack(spacing: .regular) {
                        HStack {
                            Text("Account")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Sign Out Button
                        Button(action: {
                            Task {
                                await authService.signOut()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.red)
                                
                                Text("Sign Out")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.glassBorder, lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color.appBackground)
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            themeManager.toggleMode()
                        }
                    }) {
                        Image(systemName: "moon.circle.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
            // Remove forced color scheme - let system handle theme adaptation
            .sheet(isPresented: $showingProfile) {
                ProfileDetailView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsDetailView()
            }
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(Color.glassBorder, lineWidth: 1)
                            )
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Placeholder Views
struct ProfileDetailView: View {
    var body: some View {
        Text("Profile Details")
            // Remove forced color scheme - let system handle theme adaptation
    }
}

struct SettingsDetailView: View {
    var body: some View {
        Text("Settings Details")
            // Remove forced color scheme - let system handle theme adaptation
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        let authService = AuthService(isPreview: true)
        let themeManager = ThemeManager()
        
        MoreView()
            .environmentObject(authService)
            .environmentObject(themeManager)
            .previewDisplayName("More View - Native iOS Controls")
    }
}