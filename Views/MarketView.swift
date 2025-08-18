//
//  MarketView.swift
//  The Vehicle Passport
//
//  Created by Shawn Kelshaw on August 2025.
//

// Reference: Docs/HIG_REFERENCE.md, Design/DESIGN_SYSTEM.md, Docs/GLASS_EFFECT_IMPLEMENTATION.md
// Constraints:
// - Use Apple-native SwiftUI controls (full library permitted)
// - Follow iOS 26 Human Interface Guidelines and visual system
// - Apply `.glassBackgroundEffect()` where appropriate
// - Avoid custom or third-party UI unless explicitly approved
// - Support portrait and landscape on iPhone and iPad
// - Use semantic spacing (see SystemSpacing.swift)

import SwiftUI
import Charts

struct MarketView: View {
    @EnvironmentObject var garageViewModel: GarageViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .medium) {
                    if garageViewModel.vehiclePassports.isEmpty {
                        // STATE 1: No passports
                        EmptyMarketView()
                    } else {
                        // STATE 2: Has passports  
                        VehicleMarketView()
                    }
                }
                .padding()
            }
            .navigationTitle("Market")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Empty State
struct EmptyMarketView: View {
    var body: some View {
        VStack(spacing: .regular) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Market Insights")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add a vehicle passport to see market data and resale values")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Vehicle Market State
struct VehicleMarketView: View {
    @EnvironmentObject var garageViewModel: GarageViewModel
    
    var body: some View {
        let passportCount = garageViewModel.vehiclePassports.count
        
        if passportCount == 1 {
            // Single card - no carousel needed
            if let passport = garageViewModel.vehiclePassports.first,
               let vehicle = garageViewModel.vehicles.first(where: { $0.id == passport.vehicleId }) {
                VehicleMarketList(vehicle: vehicle, passport: passport)
                    .padding(.horizontal)
            }
        } else if passportCount > 1 {
            // Multiple vehicles - carousel with dots outside
            VStack(spacing: .medium) {
                TabView {
                    ForEach(Array(garageViewModel.vehiclePassports.enumerated()), id: \.offset) { index, passport in
                        if let vehicle = garageViewModel.vehicles.first(where: { $0.id == passport.vehicleId }) {
                            VehicleMarketList(vehicle: vehicle, passport: passport)
                                .padding(.horizontal)
                        } else {
                            LoadingMarketCard(passport: passport)
                                .padding(.horizontal)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 500) // Increased height to prevent cutoff
                
                // Page indicators outside the content
                HStack(spacing: 8) {
                    ForEach(0..<passportCount, id: \.self) { index in
                        Circle()
                            .fill(Color.primary.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.bottom)
            }
        } else {
            // Empty state
            EmptyMarketView()
        }
    }
}

// MARK: - Vehicle Market List
struct VehicleMarketList: View {
    let vehicle: Vehicle
    let passport: VehiclePassport
    
    // Placeholder valuation calculation
    private var currentValuation: Double {
        let baseValue = 35000.0 // Placeholder base value
        let ageDepreciation = Double(2024 - vehicle.year) * 0.15 * baseValue
        return max(baseValue - ageDepreciation, baseValue * 0.3)
    }
    
    private var valuationTrend: String {
        let age = 2024 - vehicle.year
        return age < 3 ? "↗ +2.1%" : age < 6 ? "→ -0.5%" : "↘ -3.2%"
    }
    
    // Mock data for chart
    private var chartData: [TrendDataPoint] {
        [
            TrendDataPoint(month: "Jan", depreciation: 0.95, demand: 1.02),
            TrendDataPoint(month: "Feb", depreciation: 0.92, demand: 0.98),
            TrendDataPoint(month: "Mar", depreciation: 0.89, demand: 1.05),
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: .medium) {
                // Standard Vehicle Header (matching My Garage)
                HStack {
                    VStack(alignment: .leading, spacing: .extraTight) {
                        Text(vehicle.make)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(vehicle.model)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "car.fill")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.secondary)
                }
                
                // Standard Vehicle Data Grid (matching My Garage)
                VStack(spacing: .regular) {
                    // Top row: Year and VIN
                    HStack(spacing: .medium) {
                        VStack(spacing: .extraTight) {
                            Text("\(vehicle.year)")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Year")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 1)
                            .frame(maxHeight: 30)
                        
                        VStack(spacing: .extraTight) {
                            Text(vehicle.vin ?? "Unknown")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                            
                            Text("VIN")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Bottom row: Only Mileage (Model removed)
                    HStack(spacing: .medium) {
                        Spacer()
                        
                        VStack(spacing: .extraTight) {
                            Text("\(vehicle.mileage ?? 0)")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.green)
                            
                            Text("Mileage")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                
                // Market Value and Trend
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: .extraTight) {
                        Text("Market Value")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(NumberFormatter.currency.string(from: NSNumber(value: currentValuation)) ?? "$0")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: .extraTight) {
                        Text("3-Month Trend")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(valuationTrend)
                            .font(.title3.weight(.medium))
                            .foregroundStyle(valuationTrend.contains("+") ? .green : .red)
                    }
                }
                
                // Swift Charts
                VStack(alignment: .leading, spacing: .tight) {
                    Chart(chartData) { dataPoint in
                        LineMark(
                            x: .value("Month", dataPoint.month),
                            y: .value("Depreciation", dataPoint.depreciation)
                        )
                        .foregroundStyle(.red)
                        .symbol(.circle)
                        
                        LineMark(
                            x: .value("Month", dataPoint.month),
                            y: .value("Demand", dataPoint.demand)
                        )
                        .foregroundStyle(.green)
                        .symbol(.square)
                    }
                    .frame(height: 120)
                    .chartYScale(domain: 0.8...1.1)
                    
                    // Legend
                    HStack(spacing: .regular) {
                        Label("Depreciation", systemImage: "circle.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                        
                        Label("Market Demand", systemImage: "square.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
                
                // Action Buttons
                HStack(spacing: .mediumTight) {
                    Button(action: {}) {
                        Text("Sell Now")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, .mediumTight)
                            .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button(action: {}) {
                        Text("Get Quote")
                            .font(.headline)
                            .foregroundStyle(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, .mediumTight)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.loose)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.glassBorder, lineWidth: 1)
                    )
            )
            
            Spacer(minLength: 0)
        }
    }
    
    private func formatVIN(_ vin: String) -> String {
        vin.count > 6 ? "..." + String(vin.suffix(6)) : vin
    }
    
    private func formatMileage(_ mileage: Int?) -> String {
        guard let mileage = mileage else { return "Unknown" }
        return NumberFormatter.localizedString(from: NSNumber(value: mileage), number: .decimal)
    }
}

// MARK: - Supporting Views
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)
        }
    }
}

struct TrendDataPoint: Identifiable {
    let id = UUID()
    let month: String
    let depreciation: Double
    let demand: Double
}

extension NumberFormatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }()
}

// MARK: - Loading State Card
struct LoadingMarketCard: View {
    let passport: VehiclePassport
    
    var body: some View {
        List {
            Section("Loading Market Data") {
                VStack(spacing: .regular) {
                    HStack {
                        VStack(alignment: .leading, spacing: .extraTight) {
                            Text(passport.title ?? "Vehicle")
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.primary)
                            
                            Text("Loading market analysis...")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        ProgressView()
                    }
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(.ultraThinMaterial)
    }
}

struct MarketView_Previews: PreviewProvider {
    static var previews: some View {
        let authService = AuthService(isPreview: true)
        let garageViewModel = GarageViewModel(authService: authService)
        
        MarketView()
            .environmentObject(garageViewModel)
    }
}
