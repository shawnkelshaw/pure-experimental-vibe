import Foundation

struct VehiclePassport: Identifiable, Codable {
    let id: UUID
    let vehicleId: UUID
    let userId: UUID?
    let title: String?
    let notes: String?
    let purchaseDate: Date?
    let purchasePrice: Double?
    let currentValue: Double?
    let isActive: Bool
    let qrCode: String?
    let createdAt: Date
    let updatedAt: Date
    
    // These will be populated when we fetch related data
    var documents: [VehicleDocument] = []
    var maintenanceRecords: [MaintenanceRecord] = []
    
    init(
        id: UUID = UUID(),
        vehicleId: UUID,
        userId: UUID? = nil,
        title: String? = nil,
        notes: String? = nil,
        purchaseDate: Date? = nil,
        purchasePrice: Double? = nil,
        currentValue: Double? = nil,
        isActive: Bool = true,
        qrCode: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.vehicleId = vehicleId
        self.userId = userId
        self.title = title
        self.notes = notes
        self.purchaseDate = purchaseDate
        self.purchasePrice = purchasePrice
        self.currentValue = currentValue
        self.isActive = isActive
        self.qrCode = qrCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Coding Keys for Supabase mapping
    
    enum CodingKeys: String, CodingKey {
        case id
        case vehicleId = "vehicle_id"
        case userId = "user_id"
        case title
        case notes
        case purchaseDate = "purchase_date"
        case purchasePrice = "purchase_price"
        case currentValue = "current_value"
        case isActive = "is_active"
        case qrCode = "qr_code"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - VehicleDocument
struct VehicleDocument: Identifiable, Codable {
    let id: UUID
    let passportId: UUID
    let type: DocumentType
    let title: String
    let fileUrl: String
    let fileSize: Int64?
    let mimeType: String?
    let uploadedAt: Date
    
    init(
        id: UUID = UUID(),
        passportId: UUID,
        type: DocumentType,
        title: String,
        fileUrl: String,
        fileSize: Int64? = nil,
        mimeType: String? = nil,
        uploadedAt: Date = Date()
    ) {
        self.id = id
        self.passportId = passportId
        self.type = type
        self.title = title
        self.fileUrl = fileUrl
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.uploadedAt = uploadedAt
    }
    
    // MARK: - Coding Keys for Supabase mapping
    
    enum CodingKeys: String, CodingKey {
        case id
        case passportId = "passport_id"
        case type
        case title
        case fileUrl = "file_url"
        case fileSize = "file_size"
        case mimeType = "mime_type"
        case uploadedAt = "uploaded_at"
    }
}

enum DocumentType: String, CaseIterable, Codable {
    case registration = "registration"
    case insurance = "insurance"
    case maintenance = "maintenance"
    case inspection = "inspection"
    case warranty = "warranty"
    case receipt = "receipt"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .registration:
            return "Registration"
        case .insurance:
            return "Insurance"
        case .maintenance:
            return "Maintenance"
        case .inspection:
            return "Inspection"
        case .warranty:
            return "Warranty"
        case .receipt:
            return "Receipt"
        case .other:
            return "Other"
        }
    }
}

// MARK: - MaintenanceRecord
struct MaintenanceRecord: Identifiable, Codable {
    let id: UUID
    let passportId: UUID
    let type: MaintenanceType
    let description: String
    let cost: Double?
    let mileage: Int?
    let serviceProvider: String?
    let serviceDate: Date
    let nextServiceDue: Date?
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        passportId: UUID,
        type: MaintenanceType,
        description: String,
        cost: Double? = nil,
        mileage: Int? = nil,
        serviceProvider: String? = nil,
        serviceDate: Date,
        nextServiceDue: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.passportId = passportId
        self.type = type
        self.description = description
        self.cost = cost
        self.mileage = mileage
        self.serviceProvider = serviceProvider
        self.serviceDate = serviceDate
        self.nextServiceDue = nextServiceDue
        self.createdAt = createdAt
    }
    
    // MARK: - Coding Keys for Supabase mapping
    
    enum CodingKeys: String, CodingKey {
        case id
        case passportId = "passport_id"
        case type
        case description
        case cost
        case mileage
        case serviceProvider = "service_provider"
        case serviceDate = "service_date"
        case nextServiceDue = "next_service_due"
        case createdAt = "created_at"
    }
}

enum MaintenanceType: String, CaseIterable, Codable {
    case oilChange = "oil_change"
    case tireRotation = "tire_rotation"
    case brakeService = "brake_service"
    case transmission = "transmission"
    case airFilter = "air_filter"
    case batteryService = "battery_service"
    case inspection = "inspection"
    case tuneUp = "tune_up"
    case repair = "repair"
    case warranty = "warranty"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .oilChange:
            return "Oil Change"
        case .tireRotation:
            return "Tire Rotation"
        case .brakeService:
            return "Brake Service"
        case .transmission:
            return "Transmission"
        case .airFilter:
            return "Air Filter"
        case .batteryService:
            return "Battery Service"
        case .inspection:
            return "Inspection"
        case .tuneUp:
            return "Tune Up"
        case .repair:
            return "Repair"
        case .warranty:
            return "Warranty"
        case .other:
            return "Other"
        }
    }
}

