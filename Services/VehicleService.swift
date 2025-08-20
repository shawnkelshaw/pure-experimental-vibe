import Foundation

class VehicleService: ObservableObject {
    
    func fetchVehicles() async throws -> [Vehicle] {
        print("🔍 Using mock vehicles data")
        return mockVehicles()
    }
    
    func fetchVehiclePassports() async throws -> [VehiclePassport] {
        print("🔍 Using mock vehicle passports data")
        return mockVehiclePassports()
    }
    
    // MARK: - Mock Data
    
    private func mockVehicles() -> [Vehicle] {
        return [
            Vehicle(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
                make: "Tesla",
                model: "Model 3",
                year: 2023,
                vin: "5YJ3E1EA1KF123456",
                licensePlate: "TESLA123",
                mileage: 15000,
                fuelType: .electric,
                transmission: .automatic,
                color: "Pearl White",
                engineSize: "Electric Motor"
            ),
            Vehicle(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
                make: "BMW",
                model: "M3",
                year: 2022,
                vin: "WBS3R9C00NP123456",
                licensePlate: "BMW-M3X",
                mileage: 8500,
                fuelType: .gasoline,
                transmission: .automatic,
                color: "Alpine White",
                engineSize: "3.0L Twin Turbo"
            ),
            Vehicle(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                make: "Porsche",
                model: "911 Carrera",
                year: 2024,
                vin: "WP0CA2A91PS123456",
                licensePlate: "PRSCH11",
                mileage: 2100,
                fuelType: .gasoline,
                transmission: .automatic,
                color: "Guards Red",
                engineSize: "3.0L Flat-6"
            ),
            Vehicle(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440004")!,
                make: "Ford",
                model: "Mustang GT",
                year: 2023,
                vin: "1FA6P8CF1N5123456",
                licensePlate: "MUSTANG",
                mileage: 12000,
                fuelType: .gasoline,
                transmission: .manual,
                color: "Race Red",
                engineSize: "5.0L V8"
            ),
            Vehicle(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440005")!,
                make: "Audi",
                model: "RS6 Avant",
                year: 2023,
                vin: "WAUZZZ4G1N123456",
                licensePlate: "AUD-RS6",
                mileage: 6800,
                fuelType: .gasoline,
                transmission: .automatic,
                color: "Nardo Gray",
                engineSize: "4.0L Twin Turbo V8"
            )
        ]
    }
    
    private func mockVehiclePassports() -> [VehiclePassport] {
        return [
            VehiclePassport(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440011")!,
                vehicleId: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
                title: "Tesla Model 3 Passport",
                purchaseDate: Date(),
                purchasePrice: 45000,
                currentValue: 42000
            ),
            VehiclePassport(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440012")!,
                vehicleId: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
                title: "BMW M3 Passport",
                purchaseDate: Date(),
                purchasePrice: 75000,
                currentValue: 72000
            ),
            VehiclePassport(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440013")!,
                vehicleId: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                title: "Porsche 911 Passport",
                purchaseDate: Date(),
                purchasePrice: 120000,
                currentValue: 125000
            ),
            VehiclePassport(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440014")!,
                vehicleId: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440004")!,
                title: "Ford Mustang GT Passport",
                purchaseDate: Date(),
                purchasePrice: 55000,
                currentValue: 50000
            ),
            VehiclePassport(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440015")!,
                vehicleId: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440005")!,
                title: "Audi RS6 Avant Passport",
                purchaseDate: Date(),
                purchasePrice: 110000,
                currentValue: 108000
            )
        ]
    }
}