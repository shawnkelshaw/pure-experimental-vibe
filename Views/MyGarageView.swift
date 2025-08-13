import SwiftUI
import Foundation

struct MyGarageView: View {
    @EnvironmentObject var garageViewModel: GarageViewModel
    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject var authService: AuthService
    @State private var showingAddPassport = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // MARK: - Notification Timing State
    @State private var firstNotificationTimer: Timer?
    @State private var secondNotificationTimer: Timer?
    @State private var hasShownNotificationThisSession = false
    @State private var hasDismissedNotificationThisSession = false
    @State private var hasAcceptedFirstNotification = false
    
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
                        // Vehicle Passport Content - Adaptive Layout
                        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                            // iPad: Structured layout
                            VStack(spacing: 16) {
                                // Vehicle Card spans full width
                                VehicleCardView()
                                
                                // Two-column grid for additional cards
                                HStack(spacing: 16) {
                                    QuickOptionsCardView()
                                    StatisticsCardView()
                                }
                            }
                            .padding(.horizontal, 32)
                            .padding(.bottom, 40)
                        } else {
                            // iPhone: Single column layout
                            VStack(spacing: 16) {
                                // Vehicle Card
                                VehicleCardView()
                                
                                // Quick Options Section
                                QuickOptionsCardView()
                            }
                            .padding(.bottom, 100) // Space for tab bar
                        }
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
                    startBluetoothNotificationCountdown()
                }
            }
            .onDisappear {
                // Reset session state when leaving the view
                resetNotificationTimers()
                resetSessionState()
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
                            await handleNotificationAcceptance(notification)
                        },
                        onDismiss: {
                            await handleNotificationDismissal(notification)
                        }
                    )
                    .zIndex(999)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func startBluetoothNotificationCountdown() {
        print("🔔 === BLUETOOTH NOTIFICATION COUNTDOWN START ===")
        print("🔔 Session state: shown=\(hasShownNotificationThisSession), dismissed=\(hasDismissedNotificationThisSession)")
        
        // Only start countdown if we haven't shown or dismissed notification this session
        guard !hasShownNotificationThisSession && !hasDismissedNotificationThisSession else {
            print("🔔 ❌ BLOCKED: Already shown or dismissed this session")
            return
        }
        
        print("🔔 ✅ Starting 5-second countdown timer")
        
        // Start 5-second countdown
        firstNotificationTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            Task { @MainActor in
                await self.showFirstBluetoothNotification()
            }
        }
    }
    
    private func showFirstBluetoothNotification() async {
        print("🔔 ⏰ 5-second timer fired - showing first notification")
        
        // Mark as shown this session
        hasShownNotificationThisSession = true
        
        // Get user info
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
        
        print("🔔 Creating first Bluetooth notification for user \(userName)")
        
        // Create and show notification immediately (no delay)
        let notification = PendingNotification.bluetoothPassportPush(
            userId: userId,
            vehicleName: "Alan Subran"
        )
        
        await notificationService.createNotification(notification)
        notificationService.showNotification(notification)
    }
    
    private func startSecondNotificationCountdown() {
        print("🔔 ✅ Starting 10-second countdown for second notification")
        
        // Start 10-second countdown
        secondNotificationTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { _ in
            Task { @MainActor in
                await self.showSecondBluetoothNotification()
            }
        }
    }
    
    private func showSecondBluetoothNotification() async {
        print("🔔 ⏰ 10-second timer fired - showing second notification")
        
        // Get user info
        let userId: UUID
        let userName: String
        if let authUser = authService.user {
            userId = authUser.id
            userName = authUser.preferredDisplayName
        } else {
            print("🔔 🎭 PREVIEW MODE: Using mock user data")
            userId = UUID()
            userName = "Preview User"
        }
        
        print("🔔 Creating second Bluetooth notification for user \(userName)")
        
        // Create and show second notification immediately
        let notification = PendingNotification.bluetoothPassportPush(
            userId: userId,
            vehicleName: "Maria Rodriguez"  // Different sender for second notification
        )
        
        await notificationService.createNotification(notification)
        notificationService.showNotification(notification)
    }
    
    private func handleNotificationAcceptance(_ notification: PendingNotification) async {
        print("✅ User ACCEPTED notification: \(notification.type.displayName)")
        
        // Add vehicle passport to the garage
        await garageViewModel.addVehiclePassportFromNotification(notification)
        
        // Mark notification as confirmed
        await notificationService.confirmNotification(notification)
        
        // If this was the first acceptance, start countdown for second notification
        if !hasAcceptedFirstNotification {
            hasAcceptedFirstNotification = true
            startSecondNotificationCountdown()
        }
    }
    
    private func handleNotificationDismissal(_ notification: PendingNotification) async {
        print("🚫 User DISMISSED notification: \(notification.type.displayName)")
        
        // Mark as dismissed this session (prevents re-showing)
        hasDismissedNotificationThisSession = true
        
        // Dismiss the notification
        await notificationService.dismissNotification(notification)
    }
    
    private func resetNotificationTimers() {
        print("🔔 Resetting notification timers")
        firstNotificationTimer?.invalidate()
        secondNotificationTimer?.invalidate()
        firstNotificationTimer = nil
        secondNotificationTimer = nil
    }
    
    private func resetSessionState() {
        print("🔔 Resetting session state for fresh view visit")
        hasShownNotificationThisSession = false
        hasDismissedNotificationThisSession = false
        hasAcceptedFirstNotification = false
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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
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
        .padding(.horizontal, horizontalSizeClass == .regular ? 24 : 20)
    }
}

// MARK: - Quick Options Card View
struct QuickOptionsCardView: View {
    var body: some View {
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
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Statistics Card View
struct StatisticsCardView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Vehicle Stats")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Miles")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("12,450")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Efficiency")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("4.2 mi/kWh")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Last Service")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("Oct 15, 2023")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Next Service")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("Jan 15, 2024")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
        )
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