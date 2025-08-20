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
    
    // Vehicle information from passport/vehicle data (matches My Garage display)
    let vehicleDisplayName: String
    let vehicleYear: Int
    let vehicleMake: String
    let vehicleModel: String
    let vehicleColor: String?
    let vehicleSpecs: String? // Engine/motor info
    let vehicleVin: String? // VIN (matches My Garage VehicleCardView)
    let vehicleMileage: Int? // Mileage (matches My Garage VehicleCardView)
    
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
                city: "Savannah",
                state: "GA",
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
                city: "Savannah",
                state: "GA",
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
                city: "Savannah",
                state: "GA",
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
                city: "Savannah",
                state: "GA",
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
                city: "Savannah",
                state: "GA",
                createdAt: Date()
            )
        ]
        
        return mockData
    }
    
    // Generate resale value using real vehicle passport data
    func generateResaleValue(for passport: VehiclePassport, with vehicleData: Vehicle? = nil) -> VehicleResaleValue {
        // Extract vehicle info from passport title (fallback if no vehicle data)
        let vehicleInfo = extractVehicleInfo(from: passport, with: vehicleData)
        
        // Calculate realistic base value using actual vehicle data
        let baseValue = calculateRealisticBaseValue(
            make: vehicleInfo.make,
            model: vehicleInfo.model,
            year: vehicleInfo.year,
            purchasePrice: passport.purchasePrice
        )
        
        // Calculate market factors based on vehicle age and type
        let marketFactors = calculateMarketFactors(
            year: vehicleInfo.year,
            make: vehicleInfo.make,
            mileage: vehicleData?.mileage
        )
        
        let trendDirection = determineTrendDirection(for: vehicleInfo.make, year: vehicleInfo.year)
        let projectedValues = generateProjectedValues(baseValue: baseValue, trend: trendDirection)
        
        return VehicleResaleValue(
            id: UUID(),
            vehiclePassportId: passport.id,
            currentValue: baseValue,
            projectedValues: projectedValues,
            trendDirection: trendDirection,
            lastUpdated: Date(),
            vehicleDisplayName: vehicleInfo.displayName,
            vehicleYear: vehicleInfo.year,
            vehicleMake: vehicleInfo.make,
            vehicleModel: vehicleInfo.model,
            vehicleColor: vehicleInfo.color,
            vehicleSpecs: vehicleInfo.specs,
            vehicleVin: vehicleInfo.vin,
            vehicleMileage: vehicleInfo.mileage,
            mileageImpact: marketFactors.mileageImpact,
            ageImpact: marketFactors.ageImpact,
            marketConditionImpact: marketFactors.marketConditionImpact
        )
    }
    
    // Legacy method for backward compatibility
    func generateMockResaleValue(for vehicle: VehiclePassport) -> VehicleResaleValue {
        return generateResaleValue(for: vehicle, with: nil)
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
    
    // MARK: - Real Vehicle Data Processing
    
    private struct VehicleInfo {
        let displayName: String
        let make: String
        let model: String
        let year: Int
        let color: String?
        let specs: String?
        let vin: String?
        let mileage: Int?
    }
    
    private struct MarketFactors {
        let mileageImpact: Double
        let ageImpact: Double
        let marketConditionImpact: Double
    }
    
    private func extractVehicleInfo(from passport: VehiclePassport, with vehicleData: Vehicle?) -> VehicleInfo {
        if let vehicle = vehicleData {
            // Use EXACT vehicle data to match My Garage display
            print("📊 Using actual vehicle data: \(vehicle.year) \(vehicle.make) \(vehicle.model)")
            return VehicleInfo(
                displayName: vehicle.displayName,
                make: vehicle.make,
                model: vehicle.model,
                year: vehicle.year,
                color: vehicle.color,
                specs: vehicle.engineSize,
                vin: vehicle.vin,
                mileage: vehicle.mileage
            )
        } else {
            // Fallback: Parse from passport title (should only happen for legacy/incomplete data)
            print("⚠️ No vehicle data available, parsing from passport title: \(passport.title ?? "Unknown")")
            let title = passport.title ?? "Unknown Vehicle"
            let components = title.components(separatedBy: " ")
            
            if components.count >= 3 {
                let year = Int(components[0]) ?? 2020
                let make = components[1]
                let model = components.dropFirst(2).joined(separator: " ")
                
                return VehicleInfo(
                    displayName: title,
                    make: make,
                    model: model,
                    year: year,
                    color: nil,
                    specs: nil,
                    vin: nil,
                    mileage: nil
                )
            } else {
                return VehicleInfo(
                    displayName: title,
                    make: "Unknown",
                    model: "Unknown",
                    year: 2020,
                    color: nil,
                    specs: nil,
                    vin: nil,
                    mileage: nil
                )
            }
        }
    }
    
    private func calculateRealisticBaseValue(make: String, model: String, year: Int, purchasePrice: Double?) -> Double {
        // Base MSRP lookup table for common makes/models
        let basePrices: [String: [String: Double]] = [
            "Tesla": [
                "Model 3": 45000,
                "Model S": 75000,
                "Model X": 85000,
                "Model Y": 52000
            ],
            "Honda": [
                "Civic": 24000,
                "Accord": 28000,
                "CR-V": 32000,
                "Pilot": 38000
            ],
            "RAM": [
                "1500": 38000,
                "2500": 45000,
                "3500": 50000
            ],
            "Jeep": [
                "Wrangler": 36000,
                "Grand Cherokee": 42000,
                "Cherokee": 34000
            ],
            "Land Rover": [
                "Range Rover": 95000,
                "Range Rover Sport": 75000,
                "Discovery": 58000
            ]
        ]
        
        // Get base price or use purchase price as fallback
        let basePrice: Double
        if let makeDict = basePrices[make], let modelPrice = makeDict[model] {
            basePrice = modelPrice
        } else if let purchasePrice = purchasePrice {
            basePrice = purchasePrice
        } else {
            basePrice = 35000 // Default fallback
        }
        
        // Apply depreciation based on vehicle age
        let currentYear = Calendar.current.component(.year, from: Date())
        let vehicleAge = max(0, currentYear - year)
        
        // Different depreciation rates by brand
        let depreciationRate: Double
        switch make.lowercased() {
        case "tesla":
            depreciationRate = 0.12 // Tesla holds value better
        case "honda", "toyota":
            depreciationRate = 0.15 // Reliable brands
        case "land rover", "bmw", "audi":
            depreciationRate = 0.20 // Luxury brands depreciate faster
        default:
            depreciationRate = 0.18 // Average
        }
        
        let depreciationFactor = max(0.3, 1.0 - (Double(vehicleAge) * depreciationRate))
        return basePrice * depreciationFactor
    }
    
    private func calculateMarketFactors(year: Int, make: String, mileage: Int?) -> MarketFactors {
        let currentYear = Calendar.current.component(.year, from: Date())
        let vehicleAge = max(0, currentYear - year)
        
        // Age impact (more negative for older vehicles)
        let ageImpact = -Double(vehicleAge) * 0.025 // -2.5% per year
        
        // Mileage impact (if available)
        let mileageImpact: Double
        if let mileage = mileage {
            let averageMilesPerYear = 12000
            let expectedMileage = vehicleAge * averageMilesPerYear
            let mileageDifference = mileage - expectedMileage
            mileageImpact = -Double(mileageDifference) / 100000.0 // -1% per 10k excess miles
        } else {
            mileageImpact = Double.random(in: (-0.15)...0.05) // Random for unknown mileage
        }
        
        // Market condition impact (brand-specific)
        let marketConditionImpact: Double
        switch make.lowercased() {
        case "tesla":
            marketConditionImpact = 0.10 // EV market is hot
        case "honda", "toyota":
            marketConditionImpact = 0.05 // Reliable brands in demand
        case "jeep":
            marketConditionImpact = 0.08 // SUVs popular
        default:
            marketConditionImpact = Double.random(in: (-0.05)...0.10)
        }
        
        return MarketFactors(
            mileageImpact: mileageImpact,
            ageImpact: ageImpact,
            marketConditionImpact: marketConditionImpact
        )
    }
    
    private func determineTrendDirection(for make: String, year: Int) -> TrendDirection {
        let currentYear = Calendar.current.component(.year, from: Date())
        let vehicleAge = currentYear - year
        
        // Newer vehicles and popular brands tend to hold value better
        switch make.lowercased() {
        case "tesla":
            return vehicleAge < 3 ? .increasing : .stable
        case "honda", "toyota":
            return vehicleAge < 5 ? .stable : .decreasing
        case "land rover", "bmw":
            return vehicleAge < 2 ? .stable : .decreasing
        default:
            return vehicleAge < 3 ? .stable : .decreasing
        }
    }
}

extension Color {
    // MARK: - Apple Semantic Colors (Preferred)
    
    // MARK: - Custom Extensions Removed
    // All custom color extensions have been removed in favor of using native semantic colors directly:
    // - Use Color.primary instead of .textPrimary
    // - Use Color.secondary instead of .textSecondary  
    // - Use Color(.systemBackground) instead of .appBackground
    // - Use Color.accentColor instead of .brandPrimary
    // - Use Color.accentColor instead of .tabBarSelectedText
    // - Use Color(.secondaryLabel) instead of .tabBarUnselectedText
    
    // MARK: - Glass Effect Colors (Semantic)
    // Note: glassBorder moved to GlassEffectModifiers.swift to avoid duplication
    
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
    
    // MARK: - Custom Brand Colors Removed
    // All custom brand colors have been eliminated in favor of Color.accentColor
    // This ensures full compliance with native iOS design and user preferences
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