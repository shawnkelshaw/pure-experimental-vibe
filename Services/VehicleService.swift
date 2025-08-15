import Foundation
import Supabase

class VehicleService {
    private let supabase = SupabaseConfig.shared.client
    
    // MARK: - Vehicle Operations
    
    func fetchUserVehicles(userId: UUID) async throws -> [Vehicle] {
        let response: [Vehicle] = try await supabase
            .from("vehicles")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    func fetchVehicleById(_ vehicleId: UUID) async throws -> Vehicle {
        print("🔧 VehicleService: Fetching vehicle by ID: \(vehicleId)")
        
        let response: [VehicleAssetData] = try await supabase
            .from("vehicle_asset")
            .select("""
                id,
                vin,
                exterior_color,
                interior_color,
                original_purchase_date,
                created_at,
                vehicle_variant!inner(
                    id,
                    engine_cylinders,
                    engine_displacement_l,
                    motor_count,
                    battery_kwh,
                    drive,
                    transmission,
                    transmission_gears,
                    fuel,
                    model_year!inner(
                        id,
                        year,
                        body,
                        doors,
                        model!inner(
                            id,
                            name,
                            make!inner(
                                id,
                                name
                            )
                        )
                    )
                )
            """)
            .eq("id", value: vehicleId.uuidString)
            .execute()
            .value
        
        guard let assetData = response.first else {
            throw VehicleServiceError.vehicleNotFound
        }
        
        return transformToVehicle(assetData)
    }
    
    func fetchAllVehicles() async throws -> [Vehicle] {
        print("🔧 VehicleService: Fetching all vehicles from new schema")
        
        do {
            // First, let's try a simple query to see if we can reach the table
            print("🔧 Testing simple vehicle_asset query...")
            struct SimpleVehicleTest: Codable {
                let id: UUID
                let vin: String
            }
            let simpleTest: [SimpleVehicleTest] = try await supabase
                .from("vehicle_asset")
                .select("id, vin")
                .limit(5)
                .execute()
                .value
            print("🔧 Simple test returned \(simpleTest.count) rows")
            
            // Query the new normalized schema with joins
            let response: [VehicleAssetData] = try await supabase
                .from("vehicle_asset")
                .select("""
                    id,
                    vin,
                    exterior_color,
                    interior_color,
                    original_purchase_date,
                    created_at,
                    vehicle_variant!inner(
                        id,
                        engine_cylinders,
                        engine_displacement_l,
                        motor_count,
                        battery_kwh,
                        drive,
                        transmission,
                        transmission_gears,
                        fuel,
                        model_year!inner(
                            id,
                            year,
                            body,
                            doors,
                            model!inner(
                                id,
                                name,
                                make!inner(
                                    id,
                                    name
                                )
                            )
                        )
                    )
                """)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            print("🔧 Complex query returned \(response.count) VehicleAssetData objects")
            
            // Transform to Vehicle models
            let vehicles = response.map { assetData in
                transformToVehicle(assetData)
            }
            
            print("🔧 VehicleService: Successfully fetched \(vehicles.count) vehicles")
            return vehicles
            
        } catch {
            print("🔧 VehicleService: ❌ Error fetching vehicles: \(error)")
            print("🔧 VehicleService: ❌ Error type: \(type(of: error))")
            if let decodingError = error as? DecodingError {
                print("🔧 VehicleService: ❌ Decoding error: \(decodingError)")
            }
            throw error
        }
    }
    
    func createVehicle(_ vehicle: Vehicle) async throws -> Vehicle {
        let response: [Vehicle] = try await supabase
            .from("vehicles")
            .insert(vehicle)
            .select()
            .execute()
            .value
        
        guard let createdVehicle = response.first else {
            throw VehicleServiceError.creationFailed
        }
        
        return createdVehicle
    }
    
    func updateVehicle(_ vehicle: Vehicle) async throws -> Vehicle {
        let response: [Vehicle] = try await supabase
            .from("vehicles")
            .update(vehicle)
            .eq("id", value: vehicle.id.uuidString)
            .select()
            .execute()
            .value
        
        guard let updatedVehicle = response.first else {
            throw VehicleServiceError.updateFailed
        }
        
        return updatedVehicle
    }
    
    func deleteVehicle(id: UUID) async throws {
        try await supabase
            .from("vehicles")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Vehicle Passport Operations
    
    func fetchVehiclePassports(userId: UUID) async throws -> [VehiclePassport] {
        let response: [VehiclePassport] = try await supabase
            .from("vehicle_passports")
            .select("""
                *,
                documents:vehicle_documents(*),
                maintenance_records:maintenance_records(*)
            """)
            .eq("user_id", value: userId.uuidString)
            .eq("is_active", value: true)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    func fetchVehiclePassport(id: UUID) async throws -> VehiclePassport? {
        let response: [VehiclePassport] = try await supabase
            .from("vehicle_passports")
            .select("""
                *,
                documents:vehicle_documents(*),
                maintenance_records:maintenance_records(*)
            """)
            .eq("id", value: id.uuidString)
            .execute()
            .value
        
        return response.first
    }
    
    func createVehiclePassport(_ passport: VehiclePassport) async throws -> VehiclePassport {
        let response: [VehiclePassport] = try await supabase
            .from("vehicle_passports")
            .insert(passport)
            .select()
            .execute()
            .value
        
        guard let createdPassport = response.first else {
            throw VehicleServiceError.creationFailed
        }
        
        return createdPassport
    }
    
    func updateVehiclePassport(_ passport: VehiclePassport) async throws -> VehiclePassport {
        let response: [VehiclePassport] = try await supabase
            .from("vehicle_passports")
            .update(passport)
            .eq("id", value: passport.id.uuidString)
            .select()
            .execute()
            .value
        
        guard let updatedPassport = response.first else {
            throw VehicleServiceError.updateFailed
        }
        
        return updatedPassport
    }
    
    func deleteVehiclePassport(id: UUID) async throws {
        try await supabase
            .from("vehicle_passports")
            .update(["is_active": false])
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Document Operations
    
    func addDocument(_ document: VehicleDocument) async throws -> VehicleDocument {
        let response: [VehicleDocument] = try await supabase
            .from("vehicle_documents")
            .insert(document)
            .select()
            .execute()
            .value
        
        guard let createdDocument = response.first else {
            throw VehicleServiceError.creationFailed
        }
        
        return createdDocument
    }
    
    func deleteDocument(id: UUID) async throws {
        try await supabase
            .from("vehicle_documents")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Maintenance Record Operations
    
    func addMaintenanceRecord(_ record: MaintenanceRecord) async throws -> MaintenanceRecord {
        let response: [MaintenanceRecord] = try await supabase
            .from("maintenance_records")
            .insert(record)
            .select()
            .execute()
            .value
        
        guard let createdRecord = response.first else {
            throw VehicleServiceError.creationFailed
        }
        
        return createdRecord
    }
    
    func updateMaintenanceRecord(_ record: MaintenanceRecord) async throws -> MaintenanceRecord {
        let response: [MaintenanceRecord] = try await supabase
            .from("maintenance_records")
            .update(record)
            .eq("id", value: record.id.uuidString)
            .select()
            .execute()
            .value
        
        guard let updatedRecord = response.first else {
            throw VehicleServiceError.updateFailed
        }
        
        return updatedRecord
    }
    
    func deleteMaintenanceRecord(id: UUID) async throws {
        try await supabase
            .from("maintenance_records")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - File Upload Operations
    
    func uploadFile(data: Data, fileName: String, bucket: String = "vehicle-files") async throws -> String {
        try await supabase.storage
            .from(bucket)
            .upload(fileName, data: data)
        
        let publicURL = try await supabase.storage
            .from(bucket)
            .getPublicURL(path: fileName)
        
        return publicURL.absoluteString
    }
    
    func deleteFile(path: String, bucket: String = "vehicle-files") async throws {
        try await supabase.storage
            .from(bucket)
            .remove(paths: [path])
    }
    
    // MARK: - Notification Operations
    
    func fetchPendingNotifications(userId: UUID) async throws -> [PendingNotification] {
        let response: [PendingNotification] = try await supabase
            .from("pending_notifications")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("is_dismissed", value: false)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    func createNotification(_ notification: PendingNotification) async throws -> PendingNotification {
        let response: [PendingNotification] = try await supabase
            .from("pending_notifications")
            .insert(notification)
            .select()
            .execute()
            .value
        
        guard let createdNotification = response.first else {
            throw VehicleServiceError.creationFailed
        }
        
        return createdNotification
    }
    
    func updateNotification(_ notification: PendingNotification) async throws -> PendingNotification {
        let response: [PendingNotification] = try await supabase
            .from("pending_notifications")
            .update(notification)
            .eq("id", value: notification.id.uuidString)
            .select()
            .execute()
            .value
        
        guard let updatedNotification = response.first else {
            throw VehicleServiceError.updateFailed
        }
        
        return updatedNotification
    }
    
    func markNotificationAsRead(id: UUID) async throws {
        try await supabase
            .from("pending_notifications")
            .update(["is_read": true])
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    func dismissNotification(id: UUID) async throws {
        try await supabase
            .from("pending_notifications")
            .update(["is_dismissed": true])
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    func deleteNotification(id: UUID) async throws {
        try await supabase
            .from("pending_notifications")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Demo/Sample Data Operations
    
    func fetchNextAvailableDemoPassport(forUser userId: UUID) async throws -> VehiclePassport? {
        // Fetch demo vehicle passports that can be assigned to this user
        // This ensures vehicle #1, #2, etc. are always the same data across all views
        let response: [VehiclePassport] = try await supabase
            .from("vehicle_passports")
            .select("""
                *,
                vehicles!vehicle_passports_vehicle_id_fkey(*),
                documents:vehicle_documents(*),
                maintenance_records:maintenance_records(*)
            """)
            .like("title", pattern: "Demo Vehicle #%")
            .eq("is_active", value: true)
            .order("title")
            .limit(10)
            .execute()
            .value
        
        // Find the first demo vehicle that this user doesn't already have
        let userPassports = try await fetchVehiclePassports(userId: userId)
        let userTitles = Set(userPassports.compactMap { $0.title })
        
        for demoPassport in response {
            if let title = demoPassport.title, !userTitles.contains(title) {
                // Create a copy for this user with new ID but same vehicle data
                let userPassport = VehiclePassport(
                    id: UUID(), // New ID for this user's copy
                    vehicleId: demoPassport.vehicleId,
                    userId: userId, // Assign to current user
                    title: demoPassport.title,
                    notes: demoPassport.notes,
                    purchaseDate: demoPassport.purchaseDate,
                    purchasePrice: demoPassport.purchasePrice,
                    currentValue: demoPassport.currentValue,
                    isActive: true,
                    qrCode: UUID().uuidString, // New QR code for this user
                    documents: demoPassport.documents,
                    maintenanceRecords: demoPassport.maintenanceRecords,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                return userPassport
            }
        }
        
        return nil
    }
}

    // MARK: - Data Transformation
    
    private func transformToVehicle(_ assetData: VehicleAssetData) -> Vehicle {
        // Extract nested data
        let variant = assetData.vehicleVariant
        let modelYear = variant.modelYear
        let model = modelYear.model
        let make = model.make
        
        // Map fuel type
        let fuelType: FuelType? = {
            switch variant.fuel?.lowercased() {
            case "gas": return .gasoline
            case "diesel": return .diesel
            case "ev": return .electric
            case "hybrid": return .hybrid
            case "phev": return .pluginHybrid
            case "ethanol": return .ethanol
            default: return nil
            }
        }()
        
        // Map transmission type
        let transmissionType: TransmissionType? = {
            switch variant.transmission?.lowercased() {
            case "mt": return .manual
            case "at": return .automatic
            case "cvt": return .cvt
            case "dct": return .semiAutomatic
            case "1spd": return .automatic // Tesla single-speed treated as automatic
            default: return nil
            }
        }()
        
        // Build engine size string
        let engineSize: String? = {
            if let cylinders = variant.engineCylinders, let displacement = variant.engineDisplacementL {
                return "\(displacement)L V\(cylinders)"
            } else if let motorCount = variant.motorCount, variant.fuel?.lowercased() == "ev" {
                return "\(motorCount) Motor\(motorCount > 1 ? "s" : "")"
            }
            return nil
        }()
        
        return Vehicle(
            id: assetData.id,
            userId: UUID(), // We'll need to handle user assignment separately
            make: make.name,
            model: model.name,
            year: modelYear.year,
            vin: assetData.vin,
            licensePlate: nil, // Not in current schema
            color: assetData.exteriorColor,
            mileage: nil, // This would come from a separate mileage tracking table
            fuelType: fuelType,
            transmission: transmissionType,
            engineSize: engineSize,
            imageUrl: nil, // Would come from photo table
            createdAt: assetData.createdAt,
            updatedAt: assetData.createdAt // Using created_at as fallback
        )
    }

// MARK: - Data Structures for New Schema

struct VehicleAssetData: Codable {
    let id: UUID
    let vin: String
    let exteriorColor: String?
    let interiorColor: String?
    let originalPurchaseDate: String?
    let createdAt: Date
    let vehicleVariant: VehicleVariantData
    
    enum CodingKeys: String, CodingKey {
        case id, vin
        case exteriorColor = "exterior_color"
        case interiorColor = "interior_color"
        case originalPurchaseDate = "original_purchase_date"
        case createdAt = "created_at"
        case vehicleVariant = "vehicle_variant"
    }
}

struct VehicleVariantData: Codable {
    let id: Int64
    let engineCylinders: Int?
    let engineDisplacementL: Double?
    let motorCount: Int?
    let batteryKwh: Double?
    let drive: String?
    let transmission: String?
    let transmissionGears: Int?
    let fuel: String?
    let modelYear: ModelYearData
    
    enum CodingKeys: String, CodingKey {
        case id
        case engineCylinders = "engine_cylinders"
        case engineDisplacementL = "engine_displacement_l"
        case motorCount = "motor_count"
        case batteryKwh = "battery_kwh"
        case drive, transmission
        case transmissionGears = "transmission_gears"
        case fuel
        case modelYear = "model_year"
    }
}

struct ModelYearData: Codable {
    let id: Int64
    let year: Int
    let body: String?
    let doors: Int?
    let model: ModelData
}

struct ModelData: Codable {
    let id: Int64
    let name: String
    let make: MakeData
}

struct MakeData: Codable {
    let id: Int64
    let name: String
}

// MARK: - Errors

enum VehicleServiceError: Error, LocalizedError {
    case creationFailed
    case updateFailed
    case deletionFailed
    case fetchFailed
    case uploadFailed
    case vehicleNotFound
    
    var errorDescription: String? {
        switch self {
        case .creationFailed:
            return "Failed to create the record"
        case .updateFailed:
            return "Failed to update the record"
        case .deletionFailed:
            return "Failed to delete the record"
        case .fetchFailed:
            return "Failed to fetch data"
        case .uploadFailed:
            return "Failed to upload file"
        case .vehicleNotFound:
            return "Vehicle not found"
        }
    }
} 