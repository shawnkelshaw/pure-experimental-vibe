import SwiftUI
import Foundation

struct MyGarageView: View {
    @EnvironmentObject var garageViewModel: GarageViewModel
    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject var authService: AuthService
    @State private var showingAddPassport = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // MARK: - Notification State
    @State private var hasShownNotificationThisSession = false
    @State private var hasDismissedNotificationThisSession = false
    
    // MARK: - Scanned Vehicle State
    @State private var scannedVehicleId: String?
    
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
                                // Vehicle Cards with carousel logic
                                VehicleCarouselView()
                            }
                            .padding(.horizontal, 32)
                            .padding(.bottom, 40)
                        } else {
                            // iPhone: Single column layout
                            VStack(spacing: 16) {
                                // Vehicle Cards with carousel logic (Photo Album and Service History now integrated)
                                VehicleCarouselView()
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
                                .fill(.ultraThinMaterial)
                                .frame(width: horizontalSizeClass == .regular ? 44 : 36, 
                                       height: horizontalSizeClass == .regular ? 44 : 36)
                                .overlay(
                                    Circle()
                                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
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
                }
            }
            .onDisappear {
                // Reset session state when leaving the view
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
                AddPassportView { vehicleId in
                    // QR scan successful - close sheet and trigger notification
                    scannedVehicleId = vehicleId
                    showingAddPassport = false
                    
                    Task {
                        await triggerBluetoothNotification(vehicleId: vehicleId)
                    }
                }
            }
            .overlay {
                // Notification Overlay
                if notificationService.showingNotification,
                   let notification = notificationService.currentNotification {
                    BluetoothNotificationView(
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
    
    private func triggerBluetoothNotification(vehicleId: String) async {
        print("🔔 === BLUETOOTH NOTIFICATION TRIGGER (QR SCANNED) ===")
        print("🔔 Session state: shown=\(hasShownNotificationThisSession), dismissed=\(hasDismissedNotificationThisSession)")
        print("🔔 Scanned Vehicle ID: \(vehicleId)")
        
        // Only trigger if we haven't shown or dismissed notification this session
        guard !hasShownNotificationThisSession && !hasDismissedNotificationThisSession else {
            print("🔔 ❌ BLOCKED: Already shown or dismissed this session")
            return
        }
        
        // Mark as shown this session
        hasShownNotificationThisSession = true
        
        // Store the scanned vehicle ID for later use
        scannedVehicleId = vehicleId
        
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
        
        print("🔔 🔍 DEBUG: Input vehicleId = '\(vehicleId)'")
        print("🔔 🔍 DEBUG: userId = \(userId)")
        print("🔔 🔍 DEBUG: userName = \(userName)")
        
        print("🔔 Creating Bluetooth notification for user \(userName)")
        
        // Create and show notification immediately with vehicle ID in metadata
        let notification = PendingNotification(
            id: UUID(),
            userId: userId,
            type: .bluetoothPassportPush,
            title: "Vehicle Passport Incoming",
            message: "A nearby vehicle is sending you a Vehicle Passport—a digital certificate that can help speed up future trade-ins.",
            metadata: [
                "vehicle_id": vehicleId,
                "sender_name": "Nearby Vehicle"
            ],
            isRead: false,
            isDismissed: false,
            scheduledFor: nil,
            createdAt: Date(),
            updatedAt: Date()
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
        
        // Reset session state to allow next QR scan
        print("🔔 Resetting session state after successful passport addition")
        hasShownNotificationThisSession = false
        hasDismissedNotificationThisSession = false
    }
    
    private func handleNotificationDismissal(_ notification: PendingNotification) async {
        print("🚫 User DISMISSED notification: \(notification.type.displayName)")
        
        // Mark as dismissed this session (prevents re-showing)
        hasDismissedNotificationThisSession = true
        
        // Dismiss the notification
        await notificationService.dismissNotification(notification)
    }
    
    private func resetSessionState() {
        print("🔔 Resetting session state for fresh view visit")
        hasShownNotificationThisSession = false
        hasDismissedNotificationThisSession = false
    }
}

// MARK: - Add Passport View
struct AddPassportView: View {
    let onQRScanSuccess: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showingQRScanner = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(.blue)
                    
                    Text("Add Vehicle Passport")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Choose how you'd like to add a vehicle passport to your garage")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .padding(.top, 40)
                
                // Method Selection Buttons
                VStack(spacing: 16) {
                    // QR Scanner Button (Primary)
                    Button(action: {
                        showingQRScanner = true
                    }) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(.blue.opacity(0.1))
                                    .frame(width: horizontalSizeClass == .regular ? 56 : 48, 
                                           height: horizontalSizeClass == .regular ? 56 : 48)
                            
                                Image(systemName: "qrcode.viewfinder")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Scan Vehicle QR Code")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("Scan a QR code on a vehicle or dealer paperwork")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Manual Entry Button (Secondary) - Disabled for now
                    Button(action: {
                        // Coming soon
                    }) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(.gray.opacity(0.1))
                                    .frame(width: horizontalSizeClass == .regular ? 56 : 48, 
                                           height: horizontalSizeClass == .regular ? 56 : 48)
                            
                                Image(systemName: "pencil")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Manual Entry")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                Text("Enter vehicle details manually (Coming Soon)")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial.opacity(0.5))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(true)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Passport")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingQRScanner) {
                QRScannerView { vehicleId in
                    showingQRScanner = false
                    onQRScanSuccess(vehicleId)
                }
            }
        }
    }
}

// MARK: - QR Scanner View
struct QRScannerView: View {
    let onVehicleIdScanned: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var garageViewModel: GarageViewModel
    
    @State private var isScanning = false
    @State private var scanProgress: Double = 0.0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Scanner UI with auto-simulation
                ZStack {
                    Rectangle()
                        .fill(.background.opacity(0.8))
                        .frame(height: 300)
                    
                    VStack(spacing: 16) {
                        // Animated scanning viewfinder
                        ZStack {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 60, weight: .thin))
                                .foregroundColor(isScanning ? .green : .blue)
                                .scaleEffect(isScanning ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.5).repeatCount(isScanning ? .max : 0), value: isScanning)
                            
                            // Progress ring
                            if isScanning {
                                Circle()
                                    .trim(from: 0, to: scanProgress)
                                    .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                    .frame(width: horizontalSizeClass == .regular ? 100 : 80, 
                                           height: horizontalSizeClass == .regular ? 100 : 80)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 2.0), value: scanProgress)
                            }
                        }
                        
                        Text(isScanning ? "Scanning..." : "Scan Vehicle QR Code")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.primary)
                        
                        Text(isScanning ? "Detecting vehicle data..." : "Point camera at vehicle's QR code\nto detect Bluetooth passport")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                }
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Detect Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                startAutoScan()
            }
        }
    }
    
    private func startAutoScan() {
        // Start scanning animation after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                isScanning = true
                scanProgress = 1.0
            }
            
            // Complete scan after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                completeScan()
            }
        }
    }
    
    private func completeScan() {
        // Use current passport count as index for next vehicle
        let nextVehicleIndex = garageViewModel.vehiclePassports.count
        
        // Pass the index as a special identifier
        let vehicleId = "FETCH_VEHICLE_AT_INDEX_\(nextVehicleIndex)"
        
        print("🔍 QR Scan Complete: Requesting vehicle at index \(nextVehicleIndex)")
        
        onVehicleIdScanned(vehicleId)
    }
}

// MARK: - Bluetooth Loading View
struct BluetoothLoadingView: View {
    @State private var isAnimating = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack(spacing: 24) {
            // Bluetooth Icon with animation
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: horizontalSizeClass == .regular ? 100 : 80, 
                           height: horizontalSizeClass == .regular ? 100 : 80)
                    .overlay(
                        Circle()
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
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

// MARK: - Vehicle Carousel View
struct VehicleCarouselView: View {
    @EnvironmentObject var garageViewModel: GarageViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        let vehicleCount = garageViewModel.vehicles.count
        
        if vehicleCount == 0 {
            // Empty state - show placeholder card
            VehicleCardView(vehicle: nil)
        } else if vehicleCount == 1 {
            // Single card - no carousel needed
            if let vehicle = garageViewModel.vehicles.first {
                VehicleCardView(vehicle: vehicle)
                    .padding(.horizontal) // System spacing for consistent width
            }
        } else {
            // Multiple cards - show carousel (HIG-compliant)
            TabView {
                ForEach(Array(garageViewModel.vehicles.enumerated()), id: \.offset) { index, vehicle in
                    VehicleCardView(vehicle: vehicle)
                        .padding(.horizontal) // System spacing for consistent width
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .frame(height: horizontalSizeClass == .regular ? 420 : 380) // Content-only height
        }
    }
}

// MARK: - Vehicle Card View
struct VehicleCardView: View {
    let vehicle: Vehicle?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 20) {
                // Vehicle Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vehicle?.make ?? "No Vehicle")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(vehicle?.model ?? "Add a vehicle passport to get started")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "car.fill")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.secondary)
                }
                
                // Vehicle Data Fields
                if let vehicle = vehicle {
                    VStack(spacing: 16) {
                        // Top row: Year and VIN
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("\(String(vehicle.year))")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("Year")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                                                    Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 1)
                            .frame(maxHeight: 30)
                            
                            VStack(spacing: 4) {
                                Text(vehicle.vin ?? "Unknown")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                Text("VIN")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Bottom row: Model and Mileage
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text(vehicle.model)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.blue)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                Text("Model")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            
                                                    Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 1)
                            .frame(maxHeight: 30)
                            
                            VStack(spacing: 4) {
                                Text("\(vehicle.mileage ?? 0)")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.green)
                                
                                Text("Mileage")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Integrated Quick Options - Photo Album and Service History
                        VStack(spacing: 16) {
                            // Photo Album Section
                            HStack {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(.blue.opacity(0.1))
                                            .frame(width: horizontalSizeClass == .regular ? 48 : 40, 
                                                   height: horizontalSizeClass == .regular ? 48 : 40)
                                        
                                        Image(systemName: "photo.on.rectangle")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.blue)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Photo Album")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text("12 Photos")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {}) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                            
                            // Service History Section  
                            HStack {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(.green.opacity(0.1))
                                            .frame(width: horizontalSizeClass == .regular ? 48 : 40, 
                                                   height: horizontalSizeClass == .regular ? 48 : 40)
                                        
                                        Image(systemName: "wrench.and.screwdriver")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.green)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Service History")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text("8 Records")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {}) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(.top, 16)
                    }
                } else {
                    // Empty state when no vehicle
                    VStack(spacing: 12) {
                        Text("No vehicle data available")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("Scan a vehicle QR code to populate this card")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(24)
        }
        .padding(.horizontal, horizontalSizeClass == .regular ? 24 : 20)
    }
}

// MARK: - Quick Options Card View
struct QuickOptionsCardView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
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
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Statistics Card View
struct StatisticsCardView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
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
                .padding(24)
            }
            
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Quick Option Row
struct QuickOptionRow: View {
    let title: String
    let action: String
    let actionColor: Color
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
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




// MARK: - QR Scanner View
struct QRScannerView: View {
    let onVehicleIdScanned: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var garageViewModel: GarageViewModel
    
    @State private var isScanning = false
    @State private var scanProgress: Double = 0.0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Scanner UI with auto-simulation
                ZStack {
                    Rectangle()
                        .fill(.background.opacity(0.8))
                        .frame(height: 300)
                    
                    VStack(spacing: 16) {
                        // Animated scanning viewfinder
                        ZStack {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 60, weight: .thin))
                                .foregroundColor(isScanning ? .green : .blue)
                                .scaleEffect(isScanning ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.5).repeatCount(isScanning ? .max : 0), value: isScanning)
                            
                            // Progress ring
                            if isScanning {
                                Circle()
                                    .trim(from: 0, to: scanProgress)
                                    .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                    .frame(width: horizontalSizeClass == .regular ? 100 : 80, 
                                           height: horizontalSizeClass == .regular ? 100 : 80)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 2.0), value: scanProgress)
                            }
                        }
                        
                        Text(isScanning ? "Scanning..." : "Scan Vehicle QR Code")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.primary)
                        
                        Text(isScanning ? "Detecting vehicle data..." : "Point camera at vehicle's QR code\nto detect Bluetooth passport")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                }
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Detect Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                startAutoScan()
            }
        }
    }
    
    private func startAutoScan() {
        // Start scanning animation after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                isScanning = true
                scanProgress = 1.0
            }
            
            // Complete scan after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                completeScan()
            }
        }
    }
    
    private func completeScan() {
        // Use current passport count as index for next vehicle
        let nextVehicleIndex = garageViewModel.vehiclePassports.count
        
        // Pass the index as a special identifier
        let vehicleId = "FETCH_VEHICLE_AT_INDEX_\(nextVehicleIndex)"
        
        print("🔍 QR Scan Complete: Requesting vehicle at index \(nextVehicleIndex)")
        
        onVehicleIdScanned(vehicleId)
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
            .previewDisplayName("My Garage View - QR in Add Passport")
    }
}
}
