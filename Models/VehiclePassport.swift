import Foundation

struct VehiclePassport: Codable, Identifiable, Equatable {
    let id: UUID
    let vehicleId: UUID
    let userId: UUID
    let title: String?
    let notes: String?
    let purchaseDate: Date?
    let purchasePrice: Decimal?
    let currentValue: Decimal?
    let isActive: Bool
    let qrCode: String?
    let documents: [VehicleDocument]
    let maintenanceRecords: [MaintenanceRecord]
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case vehicleId = "vehicle_id"
        case userId = "user_id"
        case title, notes
        case purchaseDate = "purchase_date"
        case purchasePrice = "purchase_price"
        case currentValue = "current_value"
        case isActive = "is_active"
        case qrCode = "qr_code"
        case documents
        case maintenanceRecords = "maintenance_records"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct VehicleDocument: Codable, Identifiable, Equatable {
    let id: UUID
    let passportId: UUID
    let type: DocumentType
    let title: String
    let fileUrl: String
    let fileSize: Int?
    let mimeType: String?
    let uploadedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case passportId = "passport_id"
        case type, title
        case fileUrl = "file_url"
        case fileSize = "file_size"
        case mimeType = "mime_type"
        case uploadedAt = "uploaded_at"
    }
}

struct MaintenanceRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let passportId: UUID
    let type: MaintenanceType
    let description: String
    let cost: Decimal?
    let mileage: Int?
    let serviceProvider: String?
    let serviceDate: Date
    let nextServiceDue: Date?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case passportId = "passport_id"
        case type, description, cost, mileage
        case serviceProvider = "service_provider"
        case serviceDate = "service_date"
        case nextServiceDue = "next_service_due"
        case createdAt = "created_at"
    }
}

enum DocumentType: String, Codable, CaseIterable {
    case registration = "registration"
    case insurance = "insurance"
    case inspection = "inspection"
    case warranty = "warranty"
    case receipt = "receipt"
    case manual = "manual"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .registration: return "Registration"
        case .insurance: return "Insurance"
        case .inspection: return "Inspection"
        case .warranty: return "Warranty"
        case .receipt: return "Receipt"
        case .manual: return "Manual"
        case .other: return "Other"
        }
    }
    
    var iconName: String {
        switch self {
        case .registration: return "doc.text"
        case .insurance: return "shield.fill"
        case .inspection: return "checkmark.seal"
        case .warranty: return "doc.badge.gearshape"
        case .receipt: return "receipt"
        case .manual: return "book.fill"
        case .other: return "doc"
        }
    }
}

enum MaintenanceType: String, Codable, CaseIterable {
    case oilChange = "oil_change"
    case tireRotation = "tire_rotation"
    case brakeService = "brake_service"
    case inspection = "inspection"
    case tuneUp = "tune_up"
    case repair = "repair"
    case warranty = "warranty"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .oilChange: return "Oil Change"
        case .tireRotation: return "Tire Rotation"
        case .brakeService: return "Brake Service"
        case .inspection: return "Inspection"
        case .tuneUp: return "Tune-up"
        case .repair: return "Repair"
        case .warranty: return "Warranty Work"
        case .other: return "Other"
        }
    }
    
    var iconName: String {
        switch self {
        case .oilChange: return "drop.fill"
        case .tireRotation: return "circle.dotted"
        case .brakeService: return "stop.fill"
        case .inspection: return "magnifyingglass"
        case .tuneUp: return "wrench.fill"
        case .repair: return "hammer.fill"
        case .warranty: return "shield.checkered"
        case .other: return "gear"
        }
    }
} 