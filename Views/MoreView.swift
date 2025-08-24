import SwiftUI

struct MoreView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appointmentService: AppointmentService
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                            .frame(width: 32, height: 32)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(authService.user?.preferredDisplayName ?? "User")
                                .font(.headline)
                            
                            Text(authService.user?.email ?? "user@example.com")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
                
                // Appearance Section
                                    Section("Appearance") {
                        HStack(spacing: 12) {
                            Image(systemName: "paintbrush.fill")
                                .font(.title3)
                                .foregroundColor(.accentColor)
                                .frame(width: 32, height: 32)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Dark Mode")
                                    .font(.body)
                                
                                Text(themeManager.useSystemTheme ? "System" : (themeManager.isDarkMode ? "On" : "Off"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: { themeManager.isDarkMode },
                                set: { _ in themeManager.toggleMode() }
                            ))
                            .disabled(themeManager.useSystemTheme)
                        }
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    }
                
                // Appointments Section
                Section("Appointments") {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                            .frame(width: 32, height: 32)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Upcoming Events and Appointments")
                                .font(.body)
                            
                            Text(appointmentService.hasUpcomingAppointments ? "\(appointmentService.upcomingAppointments.count) upcoming" : "No upcoming appointments")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if appointmentService.hasUpcomingAppointments {
                            Text("\(appointmentService.upcomingAppointments.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(minWidth: 20, minHeight: 20)
                                .background(Circle().fill(Color(.systemRed)))
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // TODO: Navigate to appointments view
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
                
                // Settings Section
                Section("Settings") {
                    SettingsRow(icon: "bell.fill", title: "Notifications", subtitle: "Manage alerts", action: {
                        // TODO: Navigate to notifications settings
                    })
                    SettingsRow(icon: "lock.fill", title: "Privacy", subtitle: "Data & security", action: {
                        // TODO: Navigate to privacy settings
                    })
                    SettingsRow(icon: "questionmark.circle.fill", title: "Help", subtitle: "Support & FAQ", action: {
                        // TODO: Navigate to help
                    })
                    SettingsRow(icon: "info.circle.fill", title: "About", subtitle: "App information", action: {
                        // TODO: Navigate to about
                    })
                }
                
                // Account Section
                Section("Account") {
                    Button(action: {
                        Task {
                            await authService.signOut()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.title3)
                                .foregroundColor(Color(.systemRed))
                                .frame(width: 32, height: 32)
                            
                            Text("Sign Out")
                                .font(.body)
                                .foregroundColor(Color(.systemRed))
                            
                            Spacer()
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
            }
            .listStyle(.insetGrouped)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
            .environmentObject(AuthService(isPreview: true))
            .environmentObject(ThemeManager())
    }
}