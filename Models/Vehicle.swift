import Foundation

struct Vehicle: Identifiable, Codable {
    let id: UUID
    let userId: UUID?
    let make: String
    let model: String
    let year: Int
    let vin: String?
    let licensePlate: String?
    let color: String?
    let mileage: Int?
    let fuelType: FuelType
    let transmission: TransmissionType
    let engineSize: String?
    let imageUrl: String?
    let createdAt: Date
    let updatedAt: Date
    
    var displayName: String {
        "\(year) \(make) \(model)"
    }
    
    init(
        id: UUID = UUID(),
        userId: UUID? = nil,
        make: String,
        model: String,
        year: Int,
        vin: String? = nil,
        licensePlate: String? = nil,
        mileage: Int? = nil,
        fuelType: FuelType = .gasoline,
        transmission: TransmissionType = .automatic,
        color: String? = nil,
        engineSize: String? = nil,
        imageUrl: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.make = make
        self.model = model
        self.year = year
        self.vin = vin
        self.licensePlate = licensePlate
        self.mileage = mileage
        self.fuelType = fuelType
        self.transmission = transmission
        self.color = color
        self.engineSize = engineSize
        self.imageUrl = imageUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Coding Keys for Supabase mapping
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case make
        case model
        case year
        case vin
        case licensePlate = "license_plate"
        case color
        case mileage
        case fuelType = "fuel_type"
        case transmission
        case engineSize = "engine_size"
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum FuelType: String, CaseIterable, Codable {
    case gasoline = "gasoline"
    case diesel = "diesel"
    case electric = "electric"
    case hybrid = "hybrid"
    case pluginHybrid = "plugin_hybrid"
    case ethanol = "ethanol"
    
    var displayName: String {
        switch self {
        case .gasoline:
            return "Gasoline"
        case .diesel:
            return "Diesel"
        case .electric:
            return "Electric"
        case .hybrid:
            return "Hybrid"
        case .pluginHybrid:
            return "Plug-in Hybrid"
        case .ethanol:
            return "Ethanol"
        }
    }
}

enum TransmissionType: String, CaseIterable, Codable {
    case automatic = "automatic"
    case manual = "manual"
    case cvt = "cvt"
    case semiAutomatic = "semi_automatic"
    
    var displayName: String {
        switch self {
        case .automatic:
            return "Automatic"
        case .manual:
            return "Manual"
        case .cvt:
            return "CVT"
        case .semiAutomatic:
            return "Semi-Automatic"
        }
    }
}

