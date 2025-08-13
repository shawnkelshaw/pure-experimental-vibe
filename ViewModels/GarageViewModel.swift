import Foundation
import SwiftUI

@MainActor
class GarageViewModel: ObservableObject {
    @Published var vehiclePassports: [VehiclePassport] = []
    @Published var vehicles: [Vehicle] = []
    @Published var isLoading = false
    @Published var isBluetoothLoading = false
    @Published var errorMessage: String? = nil
    @Published var showingAddPassport = false
    @Published var hasLoadedInitialData = false
    
    private let vehicleService = VehicleService()
    private var authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
        setupNotificationObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateAuthService(_ authService: AuthService) {
        self.authService = authService
    }
    
    // MARK: - Data Loading
    
    func loadInitialData() async {
        guard !hasLoadedInitialData else { return }
        
        // For first-time users, start with empty state
        isLoading = true
        errorMessage = nil
        
        // Simulate loading delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Start with empty array for first-time user experience
        vehiclePassports = []
        vehicles = []
        
        isLoading = false
        hasLoadedInitialData = true
        
        print("📱 Initial data loaded - starting with \(vehiclePassports.count) passports")
    }
    
    func loadGarageData() async {
        guard let user = authService.user else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            async let passportsTask = vehicleService.fetchVehiclePassports(userId: user.id)
            async let vehiclesTask = vehicleService.fetchUserVehicles(userId: user.id)
            
            let (passports, fetchedVehicles) = try await (passportsTask, vehiclesTask)
            
            vehiclePassports = passports
            vehicles = fetchedVehicles
            isLoading = false
            hasLoadedInitialData = true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func loadSampleData() async {
        isLoading = true
        errorMessage = nil
        
        // Simulate loading delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // For first-use scenario, start with empty state
        // In production, this would load real data from the database
        vehiclePassports = []
        
        // Uncomment below to test with sample data
        // let samplePassports = createSamplePassports()
        // vehiclePassports = samplePassports
        
        isLoading = false
    }
    
    func loadSampleDataForTesting() async {
        isLoading = true
        errorMessage = nil
        
        // Simulate loading delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Create sample vehicle passports
        let samplePassports = createSamplePassports()
        
        vehiclePassports = samplePassports
        isLoading = false
    }
    
    func refreshData() async {
        await loadSampleData()
    }
    
    // MARK: - Vehicle Operations
    
    func createVehicle(make: String, model: String, year: Int, vin: String? = nil, color: String? = nil) async {
        guard let user = authService.user else { return }
        
        let newVehicle = Vehicle(
            id: UUID(),
            userId: user.id,
            make: make,
            model: model,
            year: year,
            vin: vin,
            licensePlate: nil,
            color: color,
            mileage: nil,
            fuelType: nil,
            transmission: nil,
            engineSize: nil,
            imageUrl: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        do {
            let createdVehicle = try await vehicleService.createVehicle(newVehicle)
            vehicles.append(createdVehicle)
            
            // Automatically create a passport for the new vehicle
            await createPassportForVehicle(vehicle: createdVehicle)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func createPassportForVehicle(vehicle: Vehicle) async {
        let newPassport = VehiclePassport(
            id: UUID(),
            vehicleId: vehicle.id,
            userId: vehicle.userId,
            title: vehicle.displayName,
            notes: nil,
            purchaseDate: nil,
            purchasePrice: nil,
            currentValue: nil,
            isActive: true,
            qrCode: generateQRCode(),
            documents: [],
            maintenanceRecords: [],
            createdAt: Date(),
            updatedAt: Date()
        )
        
        do {
            let createdPassport = try await vehicleService.createVehiclePassport(newPassport)
            vehiclePassports.append(createdPassport)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteVehiclePassport(_ passport: VehiclePassport) async {
        do {
            try await vehicleService.deleteVehiclePassport(id: passport.id)
            vehiclePassports.removeAll { $0.id == passport.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Document Operations
    
    func addDocument(to passport: VehiclePassport, type: DocumentType, title: String, fileData: Data, fileName: String) async {
        do {
            // Upload file
            let fileUrl = try await vehicleService.uploadFile(data: fileData, fileName: fileName)
            
            // Create document record
            let document = VehicleDocument(
                id: UUID(),
                passportId: passport.id,
                type: type,
                title: title,
                fileUrl: fileUrl,
                fileSize: fileData.count,
                mimeType: mimeTypeForFile(fileName),
                uploadedAt: Date()
            )
            
            let createdDocument = try await vehicleService.addDocument(document)
            
            // Update local passport
            if let index = vehiclePassports.firstIndex(where: { $0.id == passport.id }) {
                let updatedPassport = vehiclePassports[index]
                var documents = updatedPassport.documents
                documents.append(createdDocument)
                
                // Note: This is a simplified update - in practice you'd need to handle the nested structure properly
                vehiclePassports[index] = VehiclePassport(
                    id: updatedPassport.id,
                    vehicleId: updatedPassport.vehicleId,
                    userId: updatedPassport.userId,
                    title: updatedPassport.title,
                    notes: updatedPassport.notes,
                    purchaseDate: updatedPassport.purchaseDate,
                    purchasePrice: updatedPassport.purchasePrice,
                    currentValue: updatedPassport.currentValue,
                    isActive: updatedPassport.isActive,
                    qrCode: updatedPassport.qrCode,
                    documents: documents,
                    maintenanceRecords: updatedPassport.maintenanceRecords,
                    createdAt: updatedPassport.createdAt,
                    updatedAt: Date()
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Maintenance Operations
    
    func addMaintenanceRecord(
        to passport: VehiclePassport,
        type: MaintenanceType,
        description: String,
        cost: Decimal?,
        mileage: Int?,
        serviceProvider: String?,
        serviceDate: Date
    ) async {
        let record = MaintenanceRecord(
            id: UUID(),
            passportId: passport.id,
            type: type,
            description: description,
            cost: cost,
            mileage: mileage,
            serviceProvider: serviceProvider,
            serviceDate: serviceDate,
            nextServiceDue: calculateNextServiceDate(for: type, from: serviceDate),
            createdAt: Date()
        )
        
        do {
            let createdRecord = try await vehicleService.addMaintenanceRecord(record)
            
            // Update local passport
            if let index = vehiclePassports.firstIndex(where: { $0.id == passport.id }) {
                let updatedPassport = vehiclePassports[index]
                var maintenanceRecords = updatedPassport.maintenanceRecords
                maintenanceRecords.append(createdRecord)
                
                vehiclePassports[index] = VehiclePassport(
                    id: updatedPassport.id,
                    vehicleId: updatedPassport.vehicleId,
                    userId: updatedPassport.userId,
                    title: updatedPassport.title,
                    notes: updatedPassport.notes,
                    purchaseDate: updatedPassport.purchaseDate,
                    purchasePrice: updatedPassport.purchasePrice,
                    currentValue: updatedPassport.currentValue,
                    isActive: updatedPassport.isActive,
                    qrCode: updatedPassport.qrCode,
                    documents: updatedPassport.documents,
                    maintenanceRecords: maintenanceRecords,
                    createdAt: updatedPassport.createdAt,
                    updatedAt: Date()
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Bluetooth Notification Handling
    
    func addVehiclePassportFromNotification(_ notification: PendingNotification) async {
        print("📱 Adding vehicle passport from notification: \(notification.title)")
        
        // Extract vehicle name from notification metadata or message
        let vehicleName = notification.metadata?["sender_name"] ?? "Unknown Vehicle"
        
        // Create a demo vehicle passport with incremental numbering
        let passportNumber = vehiclePassports.count + 1
        let passportTitle = "Demo Vehicle #\(passportNumber)"
        
        let newPassport = VehiclePassport(
            id: UUID(),
            vehicleId: UUID(), // Demo vehicle ID
            userId: notification.userId,
            title: passportTitle,
            notes: "Vehicle passport received via Bluetooth from \(vehicleName)",
            purchaseDate: Date(),
            purchasePrice: nil,
            currentValue: nil,
            isActive: true,
            qrCode: generateQRCode(),
            documents: [],
            maintenanceRecords: [],
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Add to local array immediately for UI responsiveness
        vehiclePassports.append(newPassport)
        
        print("📱 Vehicle passport added: \(passportTitle) (Total: \(vehiclePassports.count))")
        print("📱 hasVehiclePassports is now: \(hasVehiclePassports)")
        
        // Note: In a real app, you would also persist this to Supabase
        // For demo purposes, we're keeping it local
    }
    
    // MARK: - Computed Properties
    
    var hasVehiclePassports: Bool {
        !vehiclePassports.isEmpty
    }
    
    var numberOfVehiclePassports: Int {
        vehiclePassports.count
    }
    
    var isFirstTimeUser: Bool {
        // In a real implementation, this would check if the user has ever had any vehicle passports
        // For now, we'll use the current empty state as an indicator
        return vehiclePassports.isEmpty && !isLoading && !isBluetoothLoading
    }
    
    // MARK: - Helper Methods
    
    private func generateQRCode() -> String {
        return UUID().uuidString
    }
    
    private func createSamplePassports() -> [VehiclePassport] {
        let sampleDocuments1 = [
            VehicleDocument(
                id: UUID(),
                passportId: UUID(),
                type: .registration,
                title: "Vehicle Registration",
                fileUrl: "https://example.com/registration.pdf",
                fileSize: 245680,
                mimeType: "application/pdf",
                uploadedAt: Date()
            ),
            VehicleDocument(
                id: UUID(),
                passportId: UUID(),
                type: .insurance,
                title: "Insurance Policy",
                fileUrl: "https://example.com/insurance.pdf",
                fileSize: 180920,
                mimeType: "application/pdf",
                uploadedAt: Date()
            )
        ]
        
        let sampleMaintenanceRecords1 = [
            MaintenanceRecord(
                id: UUID(),
                passportId: UUID(),
                type: .oilChange,
                description: "Regular oil change service",
                cost: 89.99,
                mileage: 25000,
                serviceProvider: "Quick Lube Auto",
                serviceDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
                nextServiceDue: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
                createdAt: Date()
            ),
            MaintenanceRecord(
                id: UUID(),
                passportId: UUID(),
                type: .inspection,
                description: "Annual safety inspection",
                cost: 25.00,
                mileage: 24800,
                serviceProvider: "State Inspection Center",
                serviceDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                nextServiceDue: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
                createdAt: Date()
            )
        ]
        
        let sampleDocuments2 = [
            VehicleDocument(
                id: UUID(),
                passportId: UUID(),
                type: .registration,
                title: "Vehicle Registration",
                fileUrl: "https://example.com/registration2.pdf",
                fileSize: 198765,
                mimeType: "application/pdf",
                uploadedAt: Date()
            )
        ]
        
        let sampleMaintenanceRecords2 = [
            MaintenanceRecord(
                id: UUID(),
                passportId: UUID(),
                type: .tireRotation,
                description: "Tire rotation and balance",
                cost: 65.00,
                mileage: 12000,
                serviceProvider: "Tire Pro",
                serviceDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
                nextServiceDue: Calendar.current.date(byAdding: .month, value: 5, to: Date()),
                createdAt: Date()
            )
        ]
        
        return [
            VehiclePassport(
                id: UUID(),
                vehicleId: UUID(),
                userId: UUID(),
                title: "2023 Tesla Model 3",
                notes: "Daily driver - excellent condition",
                purchaseDate: Calendar.current.date(byAdding: .year, value: -1, to: Date()),
                purchasePrice: 45000.00,
                currentValue: 42000.00,
                isActive: true,
                qrCode: generateQRCode(),
                documents: sampleDocuments1,
                maintenanceRecords: sampleMaintenanceRecords1,
                createdAt: Date(),
                updatedAt: Date()
            ),
            VehiclePassport(
                id: UUID(),
                vehicleId: UUID(),
                userId: UUID(),
                title: "2021 Honda Civic",
                notes: "Reliable commuter car",
                purchaseDate: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
                purchasePrice: 22000.00,
                currentValue: 19500.00,
                isActive: true,
                qrCode: generateQRCode(),
                documents: sampleDocuments2,
                maintenanceRecords: sampleMaintenanceRecords2,
                createdAt: Date(),
                updatedAt: Date()
            ),
            VehiclePassport(
                id: UUID(),
                vehicleId: UUID(),
                userId: UUID(),
                title: "2019 Ford F-150",
                notes: "Work truck for weekend projects",
                purchaseDate: Calendar.current.date(byAdding: .year, value: -3, to: Date()),
                purchasePrice: 32000.00,
                currentValue: 28000.00,
                isActive: true,
                qrCode: generateQRCode(),
                documents: [],
                maintenanceRecords: [],
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }
    
    private func mimeTypeForFile(_ fileName: String) -> String {
        let fileExtension = (fileName as NSString).pathExtension.lowercased()
        switch fileExtension {
        case "pdf": return "application/pdf"
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "doc": return "application/msword"
        case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        default: return "application/octet-stream"
        }
    }
    
    private func calculateNextServiceDate(for type: MaintenanceType, from serviceDate: Date) -> Date? {
        let calendar = Calendar.current
        
        switch type {
        case .oilChange:
            return calendar.date(byAdding: .month, value: 3, to: serviceDate)
        case .inspection:
            return calendar.date(byAdding: .year, value: 1, to: serviceDate)
        case .tireRotation:
            return calendar.date(byAdding: .month, value: 6, to: serviceDate)
        default:
            return nil
        }
    }
    
    // MARK: - Bluetooth Passport Handling
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBluetoothPassportAccepted),
            name: .bluetoothPassportAccepted,
            object: nil
        )
    }
    
    @objc private func handleBluetoothPassportAccepted(_ notification: Notification) {
        Task { @MainActor in
            await processBluetoothPassportAcceptance(notification)
        }
    }
    
    private func processBluetoothPassportAcceptance(_ notification: Notification) async {
        guard let userInfo = notification.userInfo,
              let senderName = userInfo["senderName"] as? String else {
            print("❌ Invalid notification data")
            return
        }
        
        print("🔔 Processing Bluetooth passport acceptance from: \(senderName)")
        
        // Start Bluetooth loading state
        isBluetoothLoading = true
        
        // Fetch real vehicle passport data from Supabase (3 seconds)
        do {
            try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            
            // Fetch the next available demo passport from Supabase
            guard let demoPassport = try await vehicleService.fetchNextAvailableDemoPassport(forUser: authService.user?.id ?? UUID()) else {
                print("❌ No demo vehicle passports available")
                isBluetoothLoading = false
                errorMessage = "No vehicle data available"
                return
            }
            
            // Create the passport in Supabase for this user
            let createdPassport = try await vehicleService.createVehiclePassport(demoPassport)
            
            // Add to the list with animation
            withAnimation(.easeInOut(duration: 0.8)) {
                vehiclePassports.insert(createdPassport, at: 0)
                isBluetoothLoading = false
            }
            
            print("✅ Supabase vehicle passport added successfully: \(createdPassport.title ?? "Unknown")")
            
        } catch {
            print("❌ Error fetching vehicle passport from Supabase: \(error)")
            isBluetoothLoading = false
            errorMessage = "Failed to receive vehicle data: \(error.localizedDescription)"
        }
    }
    
    private func createPassportFromBluetoothData(senderName: String) -> VehiclePassport {
        // Simulate creating a passport from received Bluetooth data
        return VehiclePassport(
            id: UUID(),
            vehicleId: UUID(),
            userId: authService.user?.id ?? UUID(),
            title: "2023 Tesla Model 3",
            notes: "Received from \(senderName) via Bluetooth",
            purchaseDate: Calendar.current.date(byAdding: .year, value: -1, to: Date()),
            purchasePrice: 45000.00,
            currentValue: 42000.00,
            isActive: true,
            qrCode: generateQRCode(),
            documents: createSampleDocuments(),
            maintenanceRecords: createSampleMaintenanceRecords(),
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    private func createSampleDocuments() -> [VehicleDocument] {
        return [
            VehicleDocument(
                id: UUID(),
                passportId: UUID(),
                type: .registration,
                title: "Vehicle Registration",
                fileUrl: "https://example.com/registration.pdf",
                fileSize: 245680,
                mimeType: "application/pdf",
                uploadedAt: Date()
            ),
            VehicleDocument(
                id: UUID(),
                passportId: UUID(),
                type: .insurance,
                title: "Insurance Policy",
                fileUrl: "https://example.com/insurance.pdf",
                fileSize: 180920,
                mimeType: "application/pdf",
                uploadedAt: Date()
            )
        ]
    }
    
    private func createSampleMaintenanceRecords() -> [MaintenanceRecord] {
        return [
            MaintenanceRecord(
                id: UUID(),
                passportId: UUID(),
                type: .oilChange,
                description: "Regular oil change service",
                cost: 89.99,
                mileage: 25000,
                serviceProvider: "Quick Lube Auto",
                serviceDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
                nextServiceDue: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
                createdAt: Date()
            )
        ]
    }
} 