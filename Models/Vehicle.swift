import Foundation

struct Vehicle: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let make: String
    let model: String
    let year: Int
    let vin: String?
    let licensePlate: String?
    let color: String?
    let mileage: Int?
    let fuelType: FuelType?
    let transmission: TransmissionType?
    let engineSize: String?
    let imageUrl: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case make, model, year, vin
        case licensePlate = "license_plate"
        case color, mileage
        case fuelType = "fuel_type"
        case transmission
        case engineSize = "engine_size"
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var displayName: String {
        return "\(year) \(make) \(model)"
    }
    
    var shortDescription: String {
        var components = [String]()
        components.append(displayName)
        if let color = color {
            components.append(color)
        }
        return components.joined(separator: " • ")
    }
}

enum FuelType: String, Codable, CaseIterable {
    case gasoline = "gasoline"
    case diesel = "diesel"
    case electric = "electric"
    case hybrid = "hybrid"
    case pluginHybrid = "plugin_hybrid"
    case ethanol = "ethanol"
    
    var displayName: String {
        switch self {
        case .gasoline: return "Gasoline"
        case .diesel: return "Diesel"
        case .electric: return "Electric"
        case .hybrid: return "Hybrid"
        case .pluginHybrid: return "Plug-in Hybrid"
        case .ethanol: return "Ethanol"
        }
    }
}

enum TransmissionType: String, Codable, CaseIterable {
    case manual = "manual"
    case automatic = "automatic"
    case cvt = "cvt"
    case semiAutomatic = "semi_automatic"
    
    var displayName: String {
        switch self {
        case .manual: return "Manual"
        case .automatic: return "Automatic"
        case .cvt: return "CVT"
        case .semiAutomatic: return "Semi-Automatic"
        }
    }
} 