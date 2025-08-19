import Foundation

struct Vehicle: Identifiable, Codable {
    let id: UUID
    let make: String
    let model: String
    let year: Int
    let vin: String?
    let mileage: Int?
    let fuelType: FuelType
    let transmission: TransmissionType
    let color: String?
    let engineSize: String?
    let displayName: String
    
    init(
        id: UUID = UUID(),
        make: String,
        model: String,
        year: Int,
        vin: String? = nil,
        mileage: Int? = nil,
        fuelType: FuelType = .gasoline,
        transmission: TransmissionType = .automatic,
        color: String? = nil,
        engineSize: String? = nil
    ) {
        self.id = id
        self.make = make
        self.model = model
        self.year = year
        self.vin = vin
        self.mileage = mileage
        self.fuelType = fuelType
        self.transmission = transmission
        self.color = color
        self.engineSize = engineSize
        self.displayName = "\(year) \(make) \(model)"
    }
}

enum FuelType: String, CaseIterable, Codable {
    case gasoline = "Gasoline"
    case diesel = "Diesel"
    case electric = "Electric"
    case hybrid = "Hybrid"
    case plugInHybrid = "Plug-in Hybrid"
}

enum TransmissionType: String, CaseIterable, Codable {
    case automatic = "Automatic"
    case manual = "Manual"
    case cvt = "CVT"
    case semiAutomatic = "Semi-Automatic"
}

