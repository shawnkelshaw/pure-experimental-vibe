//
//  MyGarageView.swift
//  The Vehicle Passport
//
//  Created by Shawn Kelshaw on August 2025.
//

// Reference: Docs/HIG_REFERENCE.md, Design/DESIGN_SYSTEM.md, Docs/GLASS_EFFECT_IMPLEMENTATION.md
// Constraints:
// - Use only Apple-native SwiftUI controls (full library permitted)
// - Follow iOS 26 Human Interface Guidelines and layout behavior
// - Apply `.ultraThinGlass()` and custom effects as defined
// - Avoid third-party or custom UI unless explicitly approved
// - Support iPhone and iPad in both portrait and landscape
// - Use semantic spacing (SystemSpacing.swift)

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
                    VehicleListView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
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
            .onChange(of: authService.isAuthenticated) { isAuthenticated in
                if !isAuthenticated {
                    // Reset garage state when user signs out
                    garageViewModel.resetState()
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
        await notificationService.showNotification(notification)
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
                        .foregroundColor(.accentColor)
                    
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
                
                // Method Selection List
                List {
                    Section("ADD METHOD") {
                        // QR Scanner Option
                        Button(action: {
                            showingQRScanner = true
                        }) {
                            Label {
                                VStack(alignment: .leading, spacing: .extraTight) {
                                    Text("Scan Vehicle QR Code")
                                        .font(.body.weight(.medium))
                                        .foregroundColor(.primary)
                                    
                                    Text("Scan a QR code on a vehicle or dealer paperwork")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } icon: {
                                Image(systemName: "qrcode.viewfinder")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding(.vertical, .tight)
                    
                        // Manual Entry Option (Disabled)
                        HStack {
                            Label {
                                VStack(alignment: .leading, spacing: .extraTight) {
                                    Text("Manual Entry")
                                        .font(.body.weight(.medium))
                                        .foregroundColor(.secondary)
                                    
                                    Text("Coming soon")
                                        .font(.caption)
                                        .foregroundColor(.secondary.opacity(0.5))
                                }
                            } icon: {
                                Image(systemName: "pencil")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, .tight)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                
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
    
    var body: some View {
            ZStack {
            // Full-screen black camera background
            Color.black
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Top controls bar
                HStack {
                    // Flash button (left)
                    Button(action: {}) {
                        Image(systemName: "bolt.slash")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 44)
                    
                    Spacer()
                    
                    // Chevron up (center)
                    Button(action: {}) {
                        Image(systemName: "chevron.up")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 44)
                    
                    Spacer()
                    
                    // Settings (right)
                    Button(action: {}) {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 44)
                }
                .padding(.horizontal, .medium)
                .padding(.top, .tight)
                
                // Main camera area with QR detection
                Spacer()
                
                // QR Detection area with yellow highlighting
                VStack(spacing: .medium) {
                    ZStack {
                        // QR Code image
                        Image(systemName: "qrcode")
                            .font(.system(size: 140))
                            .foregroundColor(.white)
                        
                        // Yellow detection frame (appears immediately)
                        YellowDetectionFrame()
                    }
                    .frame(width: 200, height: 200)
                    
                    // Detection banner
                    HStack(spacing: .tight) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(.systemYellow))
                            .font(.caption)
                        
                        Text("Vehicle Data Detected")
                            .foregroundColor(.black)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.horizontal, .mediumTight)
                    .padding(.vertical, .extraTight)
                    .background(
                        Capsule()
                            .fill(Color(.systemYellow))
                    )
                }
                
                Spacer()
                
                // Zoom controls
                HStack(spacing: .mediumTight) {
                    // .5x zoom
                    Button(".5") {
                        // Zoom functionality placeholder
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                Circle()
                            .fill(.black.opacity(0.5))
                    )
                    
                    // 1x zoom (highlighted as active)
                    Button("1×") {
                        // Zoom functionality placeholder
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(.white)
                    )
                    
                    // 2x zoom
                    Button("2") {
                        // Zoom functionality placeholder
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(.black.opacity(0.5))
                    )
                }
                
                Spacer()
                
                // Mode selector
                HStack(spacing: .loose) {
                    Button("SLO-MO") {
                        // Mode selection placeholder
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                    
                    Button("VIDEO") {
                        // Mode selection placeholder
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                    
                    Button("PHOTO") {
                        // Mode selection placeholder
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(.systemYellow))
                    
                    Button("PORTRAIT") {
                        // Mode selection placeholder
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                    
                    Button("PANO") {
                        // Mode selection placeholder
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                }
                .padding(.bottom, .medium)
                
                // Bottom controls
                HStack {
                    // Gallery thumbnail (left)
                    Button(action: {
                        // Gallery action placeholder
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white.opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            // Mock vehicle thumbnail
                            Image(systemName: "car.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    // Capture button (center)
                    Button(action: {
                        // Capture action - triggers scan completion
                    }) {
                        ZStack {
                            Circle()
                                .stroke(.white, lineWidth: 5)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .fill(.white)
                                .frame(width: 68, height: 68)
                        }
                    }
                    
                    Spacer()
                    
                    // Camera flip (right)
                    Button(action: {
                        // Camera flip placeholder
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                    }
                }
                .padding(.horizontal, .loose)
                .padding(.bottom, .extraLoose)
            }
        }
        .onAppear {
            startAutoScan()
        }
    }
    
    private func startAutoScan() {
        // Variable timing for realistic feel (2-4 seconds)
        let scanDuration = Double.random(in: 2.0...4.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + scanDuration) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isScanning = true
            }
            
            // Show success message briefly, then complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                completeScan()
            }
        }
    }
    
    private func completeScan() {
        // Use current accept count as index for next vehicle
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
                    .foregroundColor(.accentColor)
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
    
    var body: some View {
        let passportCount = garageViewModel.vehiclePassports.count
        
        if passportCount > 0 {
            // Vehicle list - native iOS approach
            List {
                let _ = print("🚗 List is being rendered with \(garageViewModel.vehiclePassports.count) passports")
                Section("MY PASSPORTS") {
                    ForEach(Array(garageViewModel.vehiclePassports.enumerated()), id: \.offset) { index, passport in
                        if let vehicle = garageViewModel.vehicles.first(where: { $0.id == passport.vehicleId }) {
                            NavigationLink(destination: VehicleDetailView(vehicle: vehicle)) {
                                VehicleListRow(vehicle: vehicle)
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
                            .foregroundColor(Color(.systemGreen))
                        
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
                            .foregroundColor(.accentColor)
                                        .frame(width: horizontalSizeClass == .regular ? 48 : 40, 
                                               height: horizontalSizeClass == .regular ? 48 : 40)
                                        .background(
                                            Circle()
                                                .fill(Color(.systemBlue).opacity(0.1))
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
                                        .foregroundColor(Color(.systemGreen))
                                        .frame(width: horizontalSizeClass == .regular ? 48 : 40, 
                                               height: horizontalSizeClass == .regular ? 48 : 40)
                                        .background(
                                            Circle()
                                                .fill(Color(.systemGreen).opacity(0.1))
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
                    actionColor: .accentColor
                )
                
                QuickOptionRow(
                    title: "Service History (0)",
                    action: "Manage",
                    actionColor: .accentColor
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
                            .foregroundColor(Color(.systemGreen))
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
                            .foregroundColor(Color(.systemOrange))
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
                .foregroundColor(.accentColor)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: .extraTight) {
                Text("\(String(vehicle.year)) \(vehicle.make)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
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
    
    var body: some View {
        let _ = print("🚗 VehicleDetailView - vehicle: \(vehicle.year) \(vehicle.make) \(vehicle.model)")
        let _ = print("🚗 VehicleDetailView - VIN: \(vehicle.vin ?? "nil")")
        let _ = print("🚗 VehicleDetailView - Mileage: \(vehicle.mileage?.description ?? "nil")")
        VStack(spacing: .loose) {
            // Centered Vehicle Icon
            Image(systemName: "car.fill")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.accentColor)
                .frame(width: 80, height: 80)
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
                        
                        NavigationLink(destination: OwnershipHistoryView(vehicle: vehicle)) {
                            Label("Ownership History", systemImage: "person.crop.circle.badge.questionmark.fill")
                        }
                        .padding(.vertical, .tight)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
        }
        .navigationTitle("My Passport")
        .navigationBarTitleDisplayMode(.large)
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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: .loose) {
                // Vehicle info header
                VStack(alignment: .leading, spacing: .tight) {
                    HStack {
                        Text("\(String(vehicle.year)) \(vehicle.make) - \(vehicle.model)")
                            .font(.caption)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(vehicle.vin ?? "Unknown")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, horizontalSizeClass == .regular ? .loose : .regular)
                }
                
                // External Photos Section
                VStack(alignment: .leading, spacing: .medium) {
                    Text("EXTERNAL")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .padding(.horizontal, horizontalSizeClass == .regular ? .loose : .regular)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: .tight), count: horizontalSizeClass == .regular ? 3 : 2), spacing: .tight) {
                        // External photos (8 placeholder)
                        ForEach(0..<8, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.quaternary)
                                .aspectRatio(1, contentMode: .fit)
                                .overlay {
                                    VStack(spacing: .tight) {
                                        Image(systemName: "photo")
                                            .font(.title2)
                                            .foregroundColor(.secondary)
                                        Text("External \(index + 1)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, horizontalSizeClass == .regular ? .loose : .regular)
                }
                
                // Internal Photos Section
                VStack(alignment: .leading, spacing: .medium) {
                    Text("INTERNAL")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .padding(.horizontal, horizontalSizeClass == .regular ? .loose : .regular)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: .tight), count: horizontalSizeClass == .regular ? 3 : 2), spacing: .tight) {
                        // Internal photos (8 placeholder)
                        ForEach(0..<8, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.quaternary)
                                .aspectRatio(1, contentMode: .fit)
                                .overlay {
                                    VStack(spacing: .tight) {
                                        Image(systemName: "photo")
                                            .font(.title2)
                                            .foregroundColor(.secondary)
                                        Text("Internal \(index + 1)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, horizontalSizeClass == .regular ? .loose : .regular)
                }
            }
            .padding(.vertical, .regular)
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

// MARK: - Ownership History View
struct OwnershipHistoryView: View {
    let vehicle: Vehicle
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        List {
            Section("ORIGINAL PURCHASE") {
                // Placeholder original purchase information
                OwnershipDetailRow(label: "Dealership", value: "Metro Toyota Center")
                OwnershipDetailRow(label: "Sales Agent", value: "Alan Subran")
                OwnershipDetailRow(label: "Date of Purchase", value: "March 15, \(vehicle.year)")
                OwnershipDetailRow(label: "Agent Number", value: "(555) 123-4567")
                OwnershipDetailRow(label: "Agent Email", value: "asubran@dealership.com")
            }
        }
        .navigationTitle("Ownership History")
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

// MARK: - Ownership Detail Row
struct OwnershipDetailRow: View {
    let label: String
    let value: String
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body.weight(.medium))
                .foregroundColor(.secondary)
                .frame(width: horizontalSizeClass == .regular ? 140 : 120, alignment: .leading)
            
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, .extraTight)
    }
}

// MARK: - Yellow Detection Frame
struct YellowDetectionFrame: View {
    var body: some View {
        GeometryReader { geometry in
            let cornerLength: CGFloat = .loose // 24pt
            let lineWidth: CGFloat = .extraTight // 4pt
            
            ZStack {
                // Top-left corner
                Path { path in
                    path.move(to: CGPoint(x: 0, y: cornerLength))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: cornerLength, y: 0))
                }
                .stroke(Color(.systemYellow), lineWidth: lineWidth)
                
                // Top-right corner
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width - cornerLength, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: cornerLength))
                }
                .stroke(Color(.systemYellow), lineWidth: lineWidth)
                
                // Bottom-left corner
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height - cornerLength))
                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: cornerLength, y: geometry.size.height))
                }
                .stroke(Color(.systemYellow), lineWidth: lineWidth)
                
                // Bottom-right corner
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width - cornerLength, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height - cornerLength))
                }
                .stroke(Color(.systemYellow), lineWidth: lineWidth)
            }
        }
    }
}

// MARK: - Viewfinder Overlay
struct ViewfinderOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            let cornerLength: CGFloat = .medium // 20pt
            let lineWidth: CGFloat = .extraTight // 4pt
            
            ZStack {
                // Top-left corner
                Path { path in
                    path.move(to: CGPoint(x: 0, y: cornerLength))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: cornerLength, y: 0))
                }
                .stroke(Color(.systemBlue), lineWidth: lineWidth)
                
                // Top-right corner
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width - cornerLength, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: cornerLength))
                }
                .stroke(Color(.systemBlue), lineWidth: lineWidth)
                
                // Bottom-left corner
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height - cornerLength))
                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: cornerLength, y: geometry.size.height))
                }
                .stroke(Color(.systemBlue), lineWidth: lineWidth)
                
                // Bottom-right corner
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width - cornerLength, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height - cornerLength))
                }
                .stroke(Color(.systemBlue), lineWidth: lineWidth)
            }
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
            .previewDisplayName("My Garage View - QR in Add Passport")
    }
}

