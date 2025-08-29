import Foundation
import SwiftUI

@MainActor
class GarageViewModel: ObservableObject {
    @Published var vehiclePassports: [VehiclePassport] = []
    @Published var vehicles: [Vehicle] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isBluetoothLoading = false
    
    var hasVehiclePassports: Bool {
        !vehiclePassports.isEmpty
    }
    
    private let authService: AuthService
    private let vehicleService: VehicleService
    
    // Track how many Bluetooth notifications have been accepted
    private var acceptCount = 0
    
    init(authService: AuthService) {
        self.authService = authService
        self.vehicleService = VehicleService()
        // Start with empty state - passports added via notifications
    }
    
    // MARK: - Data Loading
    
    func loadInitialData() async {
        isLoading = true
        
        // Reset accept count on fresh login
        acceptCount = 0
        
        // Test Supabase connection
        await testSupabaseConnection()
        
        isLoading = false
    }
    
    func loadGarageData() async {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        isLoading = false
    }
    
    // MARK: - Bluetooth Notification Handling
    
    func addVehiclePassportFromNotification(_ notification: PendingNotification) async {
        isBluetoothLoading = true
        errorMessage = nil
        
        do {
            let allVehicles = try await vehicleService.fetchVehicles()
            let allPassports = try await vehicleService.fetchVehiclePassports()
            
            guard acceptCount < allVehicles.count, acceptCount < allPassports.count else {
                isBluetoothLoading = false
                errorMessage = "No more vehicles available"
                return
            }
            
            let vehicle = allVehicles[acceptCount]
            let passport = allPassports[acceptCount]
            
            vehiclePassports.append(passport)
            vehicles.append(vehicle)
            acceptCount += 1
            isBluetoothLoading = false
            print("✅ Added vehicle: \(vehicle.displayName)")
            
        } catch {
            isBluetoothLoading = false
            errorMessage = "Failed to add vehicle: \(error.localizedDescription)"
            print("❌ Error: \(error)")
        }
    }
    
    // MARK: - Debug and Testing
    
        func testSupabaseConnection() async {
        print("🔍 Testing mock data connection...")
        
        do {
            let vehicles = try await vehicleService.fetchVehicles()
            let passports = try await vehicleService.fetchVehiclePassports()
            print("✅ Mock data test: \(vehicles.count) vehicles, \(passports.count) passports")
        } catch {
            print("❌ Mock data test failed: \(error)")
        }
    }
    
    // MARK: - Reset State
    
    func resetState() {
        acceptCount = 0
        vehicles.removeAll()
        vehiclePassports.removeAll()
        errorMessage = nil
    }
}

