import Foundation
import SwiftUI

// MARK: - Dealership Announcement (State 1: 0 passports)
struct DealershipAnnouncement: Codable, Identifiable {
    let id: UUID
    let dealershipName: String
    let vehicleYear: Int
    let vehicleMake: String
    let vehicleModel: String
    let originalPrice: Double
    let discountAmount: Double
    let discountPercentage: Int
    let imageUrl: String
    let city: String
    let state: String
    let createdAt: Date
    
    var vehicleDisplayName: String {
        return "\(vehicleYear) \(vehicleMake) \(vehicleModel)"
    }
    
    var finalPrice: Double {
        return originalPrice - discountAmount
    }
    
    var formattedOriginalPrice: String {
        return String(format: "$%.0f", originalPrice)
    }
    
    var formattedFinalPrice: String {
        return String(format: "$%.0f", finalPrice)
    }
    
    var formattedDiscount: String {
        return "Save \(discountPercentage)%"
    }
    
    var locationString: String {
        return "\(city), \(state)"
    }
}

// MARK: - Vehicle Resale Value (State 2: ≥1 passports)
struct VehicleResaleValue: Codable, Identifiable {
    let id: UUID
    let vehiclePassportId: UUID
    let currentValue: Double
    let projectedValues: [ResaleDataPoint]
    let trendDirection: TrendDirection
    let lastUpdated: Date
    
    // Market factors affecting resale value
    let mileageImpact: Double
    let ageImpact: Double
    let marketConditionImpact: Double
    
    var formattedCurrentValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: currentValue)) ?? String(format: "$%.0f", currentValue)
    }
    
    var trendPercentage: Double {
        guard let lastPoint = projectedValues.last else { return 0 }
        return ((lastPoint.value - currentValue) / currentValue) * 100
    }
    
    var formattedTrendPercentage: String {
        let percentage = abs(trendPercentage)
        let direction: String
        switch trendDirection {
        case .increasing:
            direction = "+"
        case .decreasing:
            direction = "-"
        case .stable:
            direction = ""
        }
        return "\(direction)\(String(format: "%.1f", percentage))%"
    }
}

struct ResaleDataPoint: Codable, Identifiable {
    let id: UUID
    let date: Date
    let value: Double
    
    init(date: Date, value: Double) {
        self.id = UUID()
        self.date = date
        self.value = value
    }
    
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}

enum TrendDirection: String, Codable, CaseIterable {
    case increasing = "increasing"
    case decreasing = "decreasing"
    case stable = "stable"
    
    var color: Color {
        switch self {
        case .increasing:
            return .green
        case .decreasing:
            return .red
        case .stable:
            return .orange
        }
    }
    
    var iconName: String {
        switch self {
        case .increasing:
            return "arrow.up.circle.fill"
        case .decreasing:
            return "arrow.down.circle.fill"
        case .stable:
            return "minus.circle.fill"
        }
    }
}

// MARK: - Mock Data Generators
class MarketDataService {
    static let shared = MarketDataService()
    
    private init() {}
    
    // Mock dealership announcements for State 1
    func generateMockDealershipAnnouncements() -> [DealershipAnnouncement] {
        let mockData = [
            DealershipAnnouncement(
                id: UUID(),
                dealershipName: "Metro Ford",
                vehicleYear: 2023,
                vehicleMake: "Ford",
                vehicleModel: "Mustang",
                originalPrice: 32995,
                discountAmount: 3000,
                discountPercentage: 9,
                imageUrl: "mustang_thumb",
                city: "Downtown",
                state: "CA",
                createdAt: Date()
            ),
            DealershipAnnouncement(
                id: UUID(),
                dealershipName: "City Toyota",
                vehicleYear: 2024,
                vehicleMake: "Toyota",
                vehicleModel: "Camry",
                originalPrice: 28450,
                discountAmount: 2500,
                discountPercentage: 8,
                imageUrl: "camry_thumb",
                city: "Westside",
                state: "CA",
                createdAt: Date()
            ),
            DealershipAnnouncement(
                id: UUID(),
                dealershipName: "Elite BMW",
                vehicleYear: 2023,
                vehicleMake: "BMW",
                vehicleModel: "3 Series",
                originalPrice: 41250,
                discountAmount: 4500,
                discountPercentage: 11,
                imageUrl: "bmw_thumb",
                city: "Uptown",
                state: "CA",
                createdAt: Date()
            ),
            DealershipAnnouncement(
                id: UUID(),
                dealershipName: "Central Honda",
                vehicleYear: 2024,
                vehicleMake: "Honda",
                vehicleModel: "Civic",
                originalPrice: 24100,
                discountAmount: 1800,
                discountPercentage: 7,
                imageUrl: "civic_thumb",
                city: "Midtown",
                state: "CA",
                createdAt: Date()
            ),
            DealershipAnnouncement(
                id: UUID(),
                dealershipName: "Premium Audi",
                vehicleYear: 2023,
                vehicleMake: "Audi",
                vehicleModel: "A4",
                originalPrice: 39800,
                discountAmount: 4200,
                discountPercentage: 10,
                imageUrl: "audi_thumb",
                city: "Eastside",
                state: "CA",
                createdAt: Date()
            )
        ]
        
        return mockData
    }
    
    // Mock resale value data for State 2
    func generateMockResaleValue(for vehicle: VehiclePassport) -> VehicleResaleValue {
        let baseValue = calculateMockBaseValue(vehicle: vehicle)
        let trendDirection = TrendDirection.allCases.randomElement() ?? .stable
        let projectedValues = generateProjectedValues(baseValue: baseValue, trend: trendDirection)
        
        return VehicleResaleValue(
            id: UUID(),
            vehiclePassportId: vehicle.id,
            currentValue: baseValue,
            projectedValues: projectedValues,
            trendDirection: trendDirection,
            lastUpdated: Date(),
            mileageImpact: Double.random(in: (-0.15)...0.05),
            ageImpact: Double.random(in: (-0.20)...(-0.05)),
            marketConditionImpact: Double.random(in: (-0.10)...0.15)
        )
    }
    
    private func calculateMockBaseValue(vehicle: VehiclePassport) -> Double {
        // Simple mock calculation - using random values for MVP
        // In real implementation, would fetch vehicle data by vehicleId
        let currentYear = Calendar.current.component(.year, from: Date())
        let mockVehicleYear = Int.random(in: 2018...2024) // Random year for mock
        let vehicleAge = currentYear - mockVehicleYear
        let basePrice = Double.random(in: 20000...60000)
        let depreciationFactor = max(0.6, 1.0 - (Double(vehicleAge) * 0.15))
        return basePrice * depreciationFactor
    }
    
    private func generateProjectedValues(baseValue: Double, trend: TrendDirection) -> [ResaleDataPoint] {
        var values: [ResaleDataPoint] = []
        let calendar = Calendar.current
        
        for month in 0...3 {
            guard let date = calendar.date(byAdding: .month, value: month, to: Date()) else { continue }
            
            let valueChange: Double
            switch trend {
            case .increasing:
                valueChange = Double(month) * 0.02 + Double.random(in: (-0.01)...0.03)
            case .decreasing:
                valueChange = (-Double(month) * 0.03) + Double.random(in: (-0.02)...0.01)
            case .stable:
                valueChange = Double.random(in: (-0.015)...0.015)
            }
            
            let projectedValue = baseValue * (1.0 + valueChange)
            values.append(ResaleDataPoint(date: date, value: projectedValue))
        }
        
        return values
    }
}

extension Color {
    // MARK: - Apple Semantic Colors (Preferred)
    
    /// Primary brand color - uses system accent color for user preference compliance
    static let brandPrimary = Color.accentColor
    
    /// Primary text color - automatically adapts to light/dark mode
    static let textPrimary = Color.primary
    
    /// Secondary text color - automatically adapts to light/dark mode  
    static let textSecondary = Color.secondary
    
    /// Primary background - uses system background with automatic adaptation
    static let appBackground = Color(.systemBackground)
    
    /// Secondary background for cards and containers
    static let cardBackground = Color(.secondarySystemBackground)
    
    /// Grouped background for lists and grouped content
    static let groupedBackground = Color(.systemGroupedBackground)
    
    /// Secondary grouped background for nested content
    static let secondaryGroupedBackground = Color(.secondarySystemGroupedBackground)
    
    // MARK: - Tab Bar Colors (Semantic)
    
    /// Selected tab item color - uses accent color for consistency
    static let tabBarSelectedText = Color.accentColor
    
    /// Unselected tab item color - uses secondary label for proper contrast
    static let tabBarUnselectedText = Color(.secondaryLabel)
    
    /// Selected tab background - uses tertiary system background
    static let tabBarSelected = Color(.tertiarySystemBackground)
    
    // MARK: - Glass Effect Colors (Semantic)
    
    /// Glass border color that adapts to light/dark mode
    static let glassBorder = Color(.separator)
    
    /// Glass highlight color for subtle overlays
    static let glassHighlight = Color(.quaternaryLabel)
    
    /// Legacy glass background - uses system material
    static let glassBackground = Color(.systemBackground).opacity(0.3)
    
    // MARK: - Status Colors (Semantic)
    
    /// Success/active status color
    static let statusSuccess = Color(.systemGreen)
    
    /// Error/inactive status color  
    static let statusError = Color(.systemRed)
    
    /// Warning status color
    static let statusWarning = Color(.systemOrange)
    
    /// Info status color
    static let statusInfo = Color(.systemBlue)
    
    // MARK: - Custom Brand Colors (When Semantic Colors Aren't Sufficient)
    
    /// Custom primary blue for brand elements that need specific color
    private static let customPrimaryBlue = Color(red: 0, green: 0.533, blue: 1.0) // #0088FF
    
    /// Brand primary blue - fallback for when accent color needs override
    static let brandBlue = customPrimaryBlue
}

// Color extension for adaptive light/dark support
extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light:
                return UIColor(light)
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(dark)
            }
        })
    }
} 