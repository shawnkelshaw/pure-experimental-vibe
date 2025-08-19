import Foundation
import SwiftUI

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
    
    init(authService: AuthService) {
        self.authService = authService
        // Start with empty state - passports added via notifications
    }
    
    private func loadMockData() {
        // Create mock vehicles for testing
        let mockVehicles = [
            Vehicle(
                make: "Tesla",
                model: "Model 3",
                year: 2018,
                vin: "1HGBH41JXMN109186",
                mileage: 45000,
                fuelType: .electric,
                transmission: .automatic,
                color: "Red",
                engineSize: "Electric"
            ),
            Vehicle(
                make: "BMW",
                model: "X5",
                year: 2020,
                vin: "5UXWX7C5*BA",
                mileage: 32000,
                fuelType: .gasoline,
                transmission: .automatic,
                color: "Blue",
                engineSize: "3.0L I6"
            )
        ]
        
        // Create mock vehicle passports
        let mockPassports = [
            VehiclePassport(
                vehicleId: mockVehicles[0].id,
                title: "Tesla Model 3"
            ),
            VehiclePassport(
                vehicleId: mockVehicles[1].id,
                title: "BMW X5"
            )
        ]
        
        self.vehicles = mockVehicles
        self.vehiclePassports = mockPassports
    }
    
    func loadInitialData() async {
        await MainActor.run {
            isLoading = true
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    func loadGarageData() async {
        await MainActor.run {
            isLoading = true
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    func addVehiclePassportFromNotification(_ notification: PendingNotification) async {
        await MainActor.run {
            isBluetoothLoading = true
        }
        
        // Simulate processing delay
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        await MainActor.run {
            isBluetoothLoading = false
            
            // Add the new vehicle and passport based on notification
            if let vehicleName = notification.metadata["vehicle_name"] ?? notification.metadata["sender_name"] {
                // Create new vehicle from notification data
                let newVehicle = Vehicle(
                    make: "Tesla", // Would come from notification metadata
                    model: "Model 3",
                    year: 2023,
                    vin: "5YJ3E1EA1NF123456",
                    mileage: 15000,
                    fuelType: .electric,
                    transmission: .automatic,
                    color: "White",
                    engineSize: "Electric"
                )
                
                // Create corresponding passport
                let newPassport = VehiclePassport(
                    vehicleId: newVehicle.id,
                    title: vehicleName
                )
                
                // Add to arrays
                self.vehicles.append(newVehicle)
                self.vehiclePassports.append(newPassport)
                
                print("✅ Added vehicle passport: \(vehicleName)")
            }
        }
    }
}

