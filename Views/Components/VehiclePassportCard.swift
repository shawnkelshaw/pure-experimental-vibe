import SwiftUI

struct VehiclePassportCard: View {
    let passport: VehiclePassport
    
    // Computed property to get vehicle display name
    private var vehicleDisplayName: String {
        if let title = passport.title, !title.isEmpty {
            return title
        }
        return "Vehicle Passport"
    }
    
    // Computed property to get vehicle details
    private var vehicleDetails: String {
        var details: [String] = []
        
        if let purchaseDate = passport.purchaseDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            details.append("Purchased: \(formatter.string(from: purchaseDate))")
        }
        
        if let purchasePrice = passport.purchasePrice {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            details.append("Price: \(formatter.string(from: purchasePrice as NSNumber) ?? "$0")")
        }
        
        if let currentValue = passport.currentValue {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            details.append("Value: \(formatter.string(from: currentValue as NSNumber) ?? "$0")")
        }
        
        return details.joined(separator: " • ")
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with title and status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(vehicleDisplayName)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    
                    Text("Active")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.textSecondary)
                    
                    // Show vehicle details if available
                    if !vehicleDetails.isEmpty {
                        Text(vehicleDetails)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Status indicator
                Circle()
                    .fill(passport.isActive ? Color.statusSuccess : Color.statusError)
                    .frame(width: 8, height: 8)
            }
            
            // Quick stats section removed
            
            // Action buttons
            HStack(spacing: 12) {
                ActionButton(
                    icon: "doc.badge.plus",
                    title: "Add Document",
                    action: {}
                )
                
                ActionButton(
                    icon: "wrench.and.screwdriver",
                    title: "Add Service",
                    action: {}
                )
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(16)
        .liquidGlassEffect(cornerRadius: 20, material: .regularMaterial)
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textPrimary)
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textPrimary)
            }
            
            Text(label)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.textSecondary)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .ultraThinGlass(cornerRadius: 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct VehiclePassportCard_Previews: PreviewProvider {
    static var previews: some View {
        VehiclePassportCard(passport: VehiclePassport(
            id: UUID(),
            vehicleId: UUID(),
            userId: UUID(),
            title: "2023 Tesla Model 3",
            notes: "Daily driver",
            purchaseDate: Date(),
            purchasePrice: 45000.00,
            currentValue: 42000.00,
            isActive: true,
            qrCode: "sample-qr-code",
            documents: [
                VehicleDocument(
                    id: UUID(),
                    passportId: UUID(),
                    type: .registration,
                    title: "Registration",
                    fileUrl: "test.pdf",
                    fileSize: 1000,
                    mimeType: "application/pdf",
                    uploadedAt: Date()
                )
            ],
            maintenanceRecords: [
                MaintenanceRecord(
                    id: UUID(),
                    passportId: UUID(),
                    type: .oilChange,
                    description: "Oil change",
                    cost: 89.99,
                    mileage: 25000,
                    serviceProvider: "Auto Shop",
                    serviceDate: Date(),
                    nextServiceDue: Date(),
                    createdAt: Date()
                )
            ],
            createdAt: Date(),
            updatedAt: Date()
        ))
        .padding()
        .background(Color.appBackground)
        .previewLayout(.sizeThatFits)
    }
} 