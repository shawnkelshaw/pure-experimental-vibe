import SwiftUI

struct MyGarageView: View {
    @EnvironmentObject var garageViewModel: GarageViewModel
    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject var authService: AuthService
    @State private var showingAddPassport = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if garageViewModel.isBluetoothLoading {
                        // Bluetooth Loading State
                        BluetoothLoadingView()
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .top)),
                                removal: .opacity
                            ))
                    } else if !garageViewModel.hasVehiclePassports {
                        // Empty State
                        VStack(spacing: 24) {
                            // Empty state content
                            VStack(spacing: 20) {
                                Image(systemName: "car.fill")
                                    .font(.system(size: 48, weight: .light))
                                    .foregroundColor(.secondary)
                                
                                VStack(spacing: 8) {
                                    Text("No Passports")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Text("You do not have any vehicle passports\nparked in your garage.")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(2)
                                }
                            }
                            .padding(.vertical, 60)
                        }
                        .padding(.horizontal, 20)
                    } else {
                        // Vehicle Passport Content
                        VStack(spacing: 16) {
                            // Vehicle Card
                            VehicleCardView()
                            
                            // Quick Options Section
                            VStack(spacing: 0) {
                                // Section Header
                                HStack {
                                    Text("Quick options")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                
                                // Quick Options Items
                                VStack(spacing: 0) {
                                    QuickOptionRow(
                                        title: "Photo Album (12)",
                                        action: "Manage",
                                        actionColor: .blue
                                    )
                                    
                                    QuickOptionRow(
                                        title: "Service History (0)",
                                        action: "Manage",
                                        actionColor: .blue
                                    )
                                }
                            }
                        }
                        .padding(.bottom, 100) // Space for tab bar
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color.appBackground)
            .navigationTitle("My Garage")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Floating Add Button
                    Button(action: {
                        showingAddPassport = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(.regularMaterial)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(Color.glassBorder, lineWidth: 1)
                                )
                            
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await garageViewModel.loadInitialData()
                    await triggerBluetoothNotificationOnVisit()
                }
            }
            .refreshable {
                await garageViewModel.loadGarageData()
            }
            .alert("Error", isPresented: .constant(garageViewModel.errorMessage != nil)) {
                Button("OK") {
                    garageViewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = garageViewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            // Remove forced color scheme - let system handle theme adaptation
            .sheet(isPresented: $showingAddPassport) {
                AddPassportView()
            }
            .overlay {
                // Notification Overlay
                if notificationService.showingNotification,
                   let notification = notificationService.currentNotification {
                    NotificationOverlayView(
                        notification: notification,
                        onConfirm: {
                            await notificationService.confirmNotification(notification)
                        },
                        onDismiss: {
                            await notificationService.dismissNotification(notification)
                        }
                    )
                    .zIndex(999)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func triggerBluetoothNotificationOnVisit() async {
        print("🔔 === BLUETOOTH NOTIFICATION TRIGGER START ===")
        print("🔔 Auth state: isAuthenticated=\(authService.isAuthenticated)")
        print("🔔 User: \(authService.user?.preferredDisplayName ?? "NO USER")")
        print("🔔 Previously dismissed: \(notificationService.bluetoothNotificationDismissed)")
        print("🔔 Has vehicle passports: \(garageViewModel.hasVehiclePassports)")
        
        // For preview/testing, create a mock user if needed
        let userId: UUID
        let userName: String
        if let authUser = authService.user {
            userId = authUser.id
            userName = authUser.preferredDisplayName
        } else {
            // Create mock user data for preview/testing
            print("🔔 🎭 PREVIEW MODE: Using mock user data")
            userId = UUID()
            userName = "Preview User"
        }
        
        // Trigger if: No passports OR notification was previously dismissed
        let shouldTrigger = !garageViewModel.hasVehiclePassports || notificationService.bluetoothNotificationDismissed
        
        if shouldTrigger {
            print("🔔 ✅ TRIGGERING: Bluetooth notification for user \(userName)")
            print("🔔 User ID: \(userId)")
            
            // Clear any existing notifications first (skip Supabase calls in preview)
            if authService.isAuthenticated {
                for notification in notificationService.pendingNotifications {
                    if notification.type == .bluetoothPassportPush {
                        await notificationService.deleteNotification(notification)
                    }
                }
            } else {
                print("🔔 🎭 PREVIEW: Skipping notification cleanup")
            }
            
            // Trigger 5-second bluetooth notification as requested
            notificationService.triggerBluetoothPassportNotification(
                userId: userId,
                vehicleName: "Alan Subran",
                delay: 5.0
            )
            
            print("🔔 ✅ Notification triggered - 5 second delay started")
        } else {
            print("🔔 ❌ BLOCKED: User has passports and notification wasn't dismissed")
            print("🔔 Reason: hasVehiclePassports=\(garageViewModel.hasVehiclePassports), dismissed=\(notificationService.bluetoothNotificationDismissed)")
        }
        
        print("🔔 === BLUETOOTH NOTIFICATION TRIGGER END ===")
    }
}

// MARK: - Bluetooth Loading View
struct BluetoothLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Bluetooth Icon with animation
            ZStack {
                Circle()
                    .fill(.regularMaterial)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color.glassBorder, lineWidth: 1)
                    )
                
                Image(systemName: "bluetooth")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(.blue)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            }
            
            VStack(spacing: 8) {
                Text("Connecting...")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("Searching for your vehicle's\nBluetooth connection.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .padding(.vertical, 60)
        .padding(.horizontal, 20)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Vehicle Card View
struct VehicleCardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
            
            VStack(spacing: 20) {
                // Vehicle Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("2023 Tesla")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Model S Plaid")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "car.fill")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.secondary)
                }
                
                // Vehicle Stats
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("12,450")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Miles")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Rectangle()
                        .fill(Color.glassBorder)
                        .frame(width: 1, height: 30)
                    
                    VStack(spacing: 4) {
                        Text("85%")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                        
                        Text("Battery")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Rectangle()
                        .fill(Color.glassBorder)
                        .frame(width: 1, height: 30)
                    
                    VStack(spacing: 4) {
                        Text("320mi")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.blue)
                        
                        Text("Range")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(24)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Quick Option Row
struct QuickOptionRow: View {
    let title: String
    let action: String
    let actionColor: Color
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(action)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(actionColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}



// MARK: - Add Passport View (Placeholder)
struct AddPassportView: View {
    var body: some View {
        NavigationStack {
            Text("Add Vehicle Passport")
                .navigationTitle("Add Passport")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MyGarageView_Previews: PreviewProvider {
    static var previews: some View {
        let authService = AuthService(isPreview: true)
        let garageViewModel = GarageViewModel(authService: authService)
        let notificationService = NotificationService()
        
        MyGarageView()
            .environmentObject(garageViewModel)
            .environmentObject(notificationService)
            .environmentObject(authService)
            .previewDisplayName("My Garage View - Native iOS Controls")
    }
}