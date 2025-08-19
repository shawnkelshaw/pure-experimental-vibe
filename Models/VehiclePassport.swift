import Foundation

struct VehiclePassport: Identifiable, Codable {
    let id: UUID
    let vehicleId: UUID
    let userId: UUID
    let title: String?
    let notes: String?
    let purchaseDate: Date?
    let purchasePrice: Double?
    let currentValue: Double?
    let isActive: Bool
    let qrCode: String?
    let documents: [VehicleDocument]
    let maintenanceRecords: [MaintenanceRecord]
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: UUID = UUID(),
        vehicleId: UUID,
        userId: UUID = UUID(),
        title: String? = nil,
        notes: String? = nil,
        purchaseDate: Date? = nil,
        purchasePrice: Double? = nil,
        currentValue: Double? = nil,
        isActive: Bool = true,
        qrCode: String? = nil,
        documents: [VehicleDocument] = [],
        maintenanceRecords: [MaintenanceRecord] = [],
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
        self.documents = documents
        self.maintenanceRecords = maintenanceRecords
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - VehicleDocument
struct VehicleDocument: Identifiable, Codable {
    let id: UUID
    let passportId: UUID
    let type: DocumentType
    let title: String
    let fileUrl: String
    let fileSize: Int64
    let mimeType: String
    let uploadedAt: Date
    
    init(
        id: UUID = UUID(),
        passportId: UUID,
        type: DocumentType,
        title: String,
        fileUrl: String,
        fileSize: Int64,
        mimeType: String,
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
    let cost: Double
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
        cost: Double,
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
}

enum MaintenanceType: String, CaseIterable, Codable {
    case oilChange = "oil_change"
    case tireRotation = "tire_rotation"
    case brakeService = "brake_service"
    case transmission = "transmission"
    case airFilter = "air_filter"
    case batteryService = "battery_service"
    case inspection = "inspection"
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
        case .other:
            return "Other"
        }
    }
}

