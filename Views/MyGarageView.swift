import SwiftUI
import Foundation

struct MyGarageView: View {
    @EnvironmentObject var garageViewModel: GarageViewModel
    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject var authService: AuthService
    @State private var showingAddPassport = false
    @State private var selectedVehicle: Vehicle?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // MARK: - Notification State
    @State private var hasShownNotificationThisSession = false
    @State private var hasDismissedNotificationThisSession = false
    
    // MARK: - Scanned Vehicle State
    @State private var scannedVehicleId: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                    if garageViewModel.isBluetoothLoading {
                        // Bluetooth Loading State
                        BluetoothLoadingView()
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .top)),
                                removal: .opacity
                            ))
                    } else if !garageViewModel.hasVehiclePassports {
                        // Empty State
                    let _ = print("🏠 Showing MAIN empty state - hasVehiclePassports: \(garageViewModel.hasVehiclePassports)")
                    VStack(spacing: .loose) {
                            // Empty state content
                        VStack(spacing: .medium) {
                                Image(systemName: "car.fill")
                                    .font(.system(size: 48, weight: .light))
                                    .foregroundColor(.secondary)
                                
                            VStack(spacing: .tight) {
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
                            .padding(.vertical, .extraLoose)
                        }
                        .padding(.horizontal, .medium)
                    } else {
                    // Vehicle Passport Content - Simplified Layout
                    let _ = print("🏠 Showing VEHICLE content - hasVehiclePassports: \(garageViewModel.hasVehiclePassports), count: \(garageViewModel.vehiclePassports.count)")
                    VehicleListView(selectedVehicle: $selectedVehicle)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .navigationTitle("My Garage")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Floating Add Button
                    Button(action: {
                        showingAddPassport = true
                    }) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            .frame(width: horizontalSizeClass == .regular ? 44 : 36, 
                                   height: horizontalSizeClass == .regular ? 44 : 36)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                    )
                            )
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
            .sheet(item: $selectedVehicle) { vehicle in
                let _ = print("🚗 Sheet opening with vehicle: \(vehicle.year) \(vehicle.make)")
                VehicleDetailView(vehicle: vehicle)
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
            VStack(spacing: .loose) {
                // Header
                VStack(spacing: .mediumTight) {
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
                                        .padding(.top, .extraLoose)
                
                // Method Selection Buttons
                VStack(spacing: .regular) {
                    // QR Scanner Button (Primary)
                    Button(action: {
                        showingQRScanner = true
                    }) {
                        HStack(spacing: .regular) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.blue)
                                .frame(width: horizontalSizeClass == .regular ? 56 : 48, 
                                       height: horizontalSizeClass == .regular ? 56 : 48)
                                .background(
                                    Circle()
                                        .fill(.blue.opacity(0.1))
                                )
                            
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
                        .padding(.horizontal, .medium)
                        .padding(.vertical, .regular)
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
                        HStack(spacing: .regular) {
                            Image(systemName: "pencil")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.gray)
                                .frame(width: horizontalSizeClass == .regular ? 56 : 48, 
                                       height: horizontalSizeClass == .regular ? 56 : 48)
                                .background(
                                    Circle()
                                        .fill(.gray.opacity(0.1))
                                )
                            
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
                        .padding(.horizontal, .medium)
                        .padding(.vertical, .regular)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial.opacity(0.5))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(true)
                }
                .padding(.horizontal, .medium)
                
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
            VStack(spacing: .medium) {
                // Scanner UI with auto-simulation
                ZStack {
                    Rectangle()
                        .fill(.background.opacity(0.8))
                        .frame(height: 300)
                    
                    VStack(spacing: .regular) {
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
        VStack(spacing: .loose) {
            // Bluetooth Icon with animation
                Image(systemName: "bluetooth")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(.blue)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                .frame(width: horizontalSizeClass == .regular ? 100 : 80, 
                       height: horizontalSizeClass == .regular ? 100 : 80)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                )
            
            VStack(spacing: .tight) {
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
        .padding(.vertical, .extraLoose)
        .padding(.horizontal, .medium)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Vehicle List View
struct VehicleListView: View {
    @EnvironmentObject var garageViewModel: GarageViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var selectedVehicle: Vehicle?
    
    var body: some View {
        let passportCount = garageViewModel.vehiclePassports.count
        
        if passportCount > 0 {
            // Vehicle list - native iOS approach
            List {
                let _ = print("🚗 List is being rendered with \(garageViewModel.vehiclePassports.count) passports")
                Section("MY PASSPORTS") {
                    ForEach(Array(garageViewModel.vehiclePassports.enumerated()), id: \.offset) { index, passport in
                        if let vehicle = garageViewModel.vehicles.first(where: { $0.id == passport.vehicleId }) {
                                                    VehicleListRow(vehicle: vehicle)
                            .onTapGesture {
                                print("🚗 Tapped vehicle: \(vehicle.year) \(vehicle.make) \(vehicle.model)")
                                selectedVehicle = vehicle
                                print("🚗 selectedVehicle set to: \(selectedVehicle?.year ?? 0) \(selectedVehicle?.make ?? "nil")")
                            }
                        } else {
                            VehicleLoadingRow(passport: passport)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                print("🚗 VehicleListView appeared - passportCount: \(passportCount)")
                print("🚗 VehicleListView - vehicles.count: \(garageViewModel.vehicles.count)")
                print("🚗 VehicleListView - passports: \(garageViewModel.vehiclePassports.map { $0.title ?? "No title" })")
            }
        } else {
            // Empty state
            EmptyGarageView()
                .onAppear {
                    print("🚗 EmptyGarageView appeared - passportCount: 0")
                    print("🚗 vehiclePassports: \(garageViewModel.vehiclePassports)")
                    print("🚗 vehicles: \(garageViewModel.vehicles)")
                }
        }
    }
}

// MARK: - Loading Garage Card
struct LoadingGarageCard: View {
    let passport: VehiclePassport
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: .medium) {
                HStack {
                    VStack(alignment: .leading, spacing: .extraTight) {
                        Text(passport.title ?? "Vehicle")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Loading vehicle data...")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    ProgressView()
                        .scaleEffect(1.2)
                }
            }
            .padding(.loose)
            .background(
            RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
            )
            
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Empty Garage View
struct EmptyGarageView: View {
    var body: some View {
        VStack(spacing: .loose) {
            Image(systemName: "car.fill")
                .font(.system(size: 60, weight: .thin))
                .foregroundColor(.secondary)
            
            VStack(spacing: .tight) {
                Text("No Vehicle Passports")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.primary)
                
                Text("Tap the + button to add your first vehicle passport")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.loose)
    }
}

// MARK: - Vehicle Card View
struct VehicleCardView: View {
    let vehicle: Vehicle
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                // Vehicle Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vehicle.make)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(vehicle.model)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "car.fill")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.secondary)
                }
                
                // Vehicle Data Fields
                VStack(spacing: .regular) {
                        // Top row: Year and VIN
                        HStack(spacing: .medium) {
                            VStack(spacing: .extraTight) {
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
                            
                            VStack(spacing: .extraTight) {
                                Text(vehicle.vin ?? "Unknown")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                                
                                Text("VIN")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Bottom row: Only Mileage (Model removed to match Market View)
                        HStack(spacing: .medium) {
                            Spacer()
                            
                            VStack(spacing: .extraTight) {
                                Text("\(vehicle.mileage ?? 0)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                        
                                Text("Mileage")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                            Spacer()
                        }
                        
                        // Integrated Quick Options - Photo Album and Service History
                        VStack(spacing: .regular) {
                            // Photo Album Section
                            HStack {
                                HStack(spacing: .mediumTight) {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.blue)
                                        .frame(width: horizontalSizeClass == .regular ? 48 : 40, 
                                               height: horizontalSizeClass == .regular ? 48 : 40)
                                        .background(
                                            Circle()
                                                .fill(.blue.opacity(0.1))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) { // Keep minimal for label pairs
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
                            .padding(.vertical, .tight)
                            
                            // Service History Section  
                            HStack {
                                HStack(spacing: .mediumTight) {
                                    Image(systemName: "wrench.and.screwdriver")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.green)
                                        .frame(width: horizontalSizeClass == .regular ? 48 : 40, 
                                               height: horizontalSizeClass == .regular ? 48 : 40)
                                        .background(
                                            Circle()
                                                .fill(.green.opacity(0.1))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) { // Keep minimal for label pairs
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
                            .padding(.vertical, .tight)
                        }
                        .padding(.top, .regular)
                    }
            }
            .padding(.loose)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            )
        }
                    .padding(.horizontal, horizontalSizeClass == .regular ? .loose : .medium)
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
            .padding(.horizontal, .regular)
            .padding(.vertical, .tight)
            
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
        .padding(.horizontal, .medium)
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
                .padding(.loose)
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
            .padding(.horizontal, .regular)
            .padding(.vertical, .mediumTight)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - Vehicle List Row
struct VehicleListRow: View {
    let vehicle: Vehicle
    
    var body: some View {
        HStack(spacing: .medium) {
            // Vehicle icon
            Image(systemName: "car.fill")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: .extraTight) {
                HStack {
                    Text("\(String(vehicle.year)) \(vehicle.make)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                }
                
                Text(vehicle.model)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("VIN: \(String(vehicle.vin?.suffix(8) ?? "Unknown"))")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, .tight)
        .contentShape(Rectangle())
    }
}

// MARK: - Vehicle Loading Row
struct VehicleLoadingRow: View {
    let passport: VehiclePassport
    
    var body: some View {
        HStack(spacing: .medium) {
            // Loading icon
            ProgressView()
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: .extraTight) {
                Text(passport.title ?? "Vehicle")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Loading vehicle data...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, .tight)
    }
}

// MARK: - Vehicle Detail View
struct VehicleDetailView: View {
    let vehicle: Vehicle
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        let _ = print("🚗 VehicleDetailView - vehicle: \(vehicle.year) \(vehicle.make) \(vehicle.model)")
        let _ = print("🚗 VehicleDetailView - VIN: \(vehicle.vin ?? "nil")")
        let _ = print("🚗 VehicleDetailView - Mileage: \(vehicle.mileage?.description ?? "nil")")
        NavigationStack {
            VStack(spacing: .loose) {
                // Centered Vehicle Icon
                Image(systemName: "car.fill")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.blue)
                    .frame(width: 80, height: 80)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.top, .medium)
                
                // Vehicle Details List
                List {
                    Section {
                        VehicleDetailRow(label: "Vehicle", value: "\(String(vehicle.year)) \(vehicle.make) - \(vehicle.model)")
                        VehicleDetailRow(label: "VIN", value: vehicle.vin ?? "Not Available")
                        VehicleDetailRow(label: "Mileage", value: formatMileage(vehicle.mileage))
                        VehicleDetailRow(label: "Color", value: vehicle.color ?? "Not Available")
                        VehicleDetailRow(label: "Valuation", value: generateMockValuation())
                        
                        // Action Links
                        NavigationLink(destination: PhotoGalleryView(vehicle: vehicle)) {
                            Label("Photo Gallery", systemImage: "camera.fill")
                        }
                        .padding(.vertical, .tight)
                        
                        NavigationLink(destination: ServiceHistoryView(vehicle: vehicle)) {
                            Label("Service History", systemImage: "wrench.and.screwdriver.fill")
                        }
                        .padding(.vertical, .tight)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("My Passport")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.body.weight(.medium))
                }
            }
        }
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Helper Functions
    
    private func formatMileage(_ mileage: Int?) -> String {
        guard let mileage = mileage else { return "Not Available" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: mileage)) ?? "\(mileage)"
    }
    
    private func generateMockValuation() -> String {
        // Generate a mock valuation range based on vehicle year
        let currentYear = Calendar.current.component(.year, from: Date())
        let vehicleAge = currentYear - vehicle.year
        
        // Base value decreases with age
        let baseValue = max(15000 - (vehicleAge * 1500), 8000)
        let minValue = baseValue - 2500
        let maxValue = baseValue + 2500
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        
        let minString = formatter.string(from: NSNumber(value: minValue)) ?? "$\(minValue)"
        let maxString = formatter.string(from: NSNumber(value: maxValue)) ?? "$\(maxValue)"
        
        return "\(minString) - \(maxString)"
    }
}

// MARK: - Vehicle Detail Row Helper
struct VehicleDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body.weight(.medium))
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, .tight)
    }
}

// MARK: - Photo Gallery View
struct PhotoGalleryView: View {
    let vehicle: Vehicle
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: .medium) {
                // Placeholder for future photos
                ForEach(0..<6, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.quaternary)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            VStack(spacing: .tight) {
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                Text("Photo \(index + 1)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                }
            }
            .padding()
        }
        .navigationTitle("Photo Gallery")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Service History View
struct ServiceHistoryView: View {
    let vehicle: Vehicle
    
    var body: some View {
        List {
            Section("RECENT SERVICE") {
                // Placeholder service records
                ServiceHistoryRow(
                    date: "Dec 15, 2024",
                    service: "Oil Change",
                    mileage: "45,230",
                    cost: "$89.99"
                )
                
                ServiceHistoryRow(
                    date: "Sep 22, 2024",
                    service: "Tire Rotation",
                    mileage: "43,150",
                    cost: "$45.00"
                )
                
                ServiceHistoryRow(
                    date: "Jun 18, 2024",
                    service: "Brake Inspection",
                    mileage: "41,890",
                    cost: "$125.00"
                )
            }
        }
        .navigationTitle("Service History")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Service History Row
struct ServiceHistoryRow: View {
    let date: String
    let service: String
    let mileage: String
    let cost: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: .extraTight) {
            HStack {
                Text(service)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(cost)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(mileage) miles")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, .extraTight)
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
