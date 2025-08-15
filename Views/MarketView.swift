import SwiftUI

struct MarketView: View {
    @EnvironmentObject var garageViewModel: GarageViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
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
        VStack(spacing: 16) {
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
                VehicleMarketCard(vehicle: vehicle, passport: passport)
                    .padding(.horizontal) // System spacing for consistent width
            }
        } else {
            // Multiple cards - show carousel (HIG-compliant)
            TabView {
                ForEach(Array(garageViewModel.vehiclePassports.enumerated()), id: \.offset) { index, passport in
                    if let vehicle = garageViewModel.vehicles.first(where: { $0.id == passport.vehicleId }) {
                        VehicleMarketCard(vehicle: vehicle, passport: passport)
                            .padding(.horizontal) // System spacing for consistent width
                    } else {
                        LoadingMarketCard(passport: passport)
                            .padding(.horizontal) // System spacing for consistent width
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .frame(height: 420) // Content-only height for HIG compliance
        }
    }
}

// MARK: - Vehicle Market Card
struct VehicleMarketCard: View {
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.glassBorder, lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 20) {
                // Vehicle Header (matching My Garage style)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
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
                
                // Vehicle Data Fields (matching My Garage layout)
                VStack(spacing: 16) {
                    // Top row: Year and VIN
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("\(String(vehicle.year))")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Year")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Rectangle()
                            .fill(Color.glassBorder)
                            .frame(width: 1)
                            .frame(maxHeight: 30)
                        
                        VStack(spacing: 4) {
                            Text(formatVIN(vehicle.vin ?? "Unknown"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            Text("VIN")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Bottom row: Model and Mileage
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text(vehicle.model)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.blue)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            Text("Model")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Rectangle()
                            .fill(Color.glassBorder)
                            .frame(width: 1)
                            .frame(maxHeight: 30)
                        
                        VStack(spacing: 4) {
                            Text(formatMileage(vehicle.mileage))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.green)
                            
                            Text("Mileage")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Market Valuation Section
                    VStack(spacing: 12) {
                        // Current Value and Trend
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Market Value")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text(formatCurrency(currentValuation))
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("3-Month Trend")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text(valuationTrend)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(valuationTrend.contains("↗") ? .green : 
                                                   valuationTrend.contains("→") ? .orange : .red)
                            }
                        }
                        
                        // Trend Chart
                        TrendChartView()
                            .frame(height: 80)
                    }
                    .padding(.top, 8)
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            Text("Sell Now")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        Button(action: {}) {
                            Text("Get Quote")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    .padding(.top, 8)
                }
                }
                .padding(24)
            }
            
            Spacer(minLength: 0)
        }
    }
    
    private func formatVIN(_ vin: String) -> String {
        return vin.count > 6 ? "..." + String(vin.suffix(6)) : vin
    }
    
    private func formatMileage(_ mileage: Int?) -> String {
        guard let mileage = mileage else { return "Unknown" }
        return NumberFormatter.localizedString(from: NSNumber(value: mileage), number: .decimal)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Loading State Card
struct LoadingMarketCard: View {
    let passport: VehiclePassport
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(passport.title ?? "Vehicle")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Loading market data...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .primary.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Trend Chart (Mock Implementation)
struct TrendChartView: View {
    var body: some View {
        ZStack {
            // Chart background
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
            
            VStack(spacing: 8) {
                // Chart title
                HStack {
                    Text("Market Trends")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                // Mock chart lines
                ZStack {
                    // Depreciation line (downward trend)
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 30))
                        path.addLine(to: CGPoint(x: 100, y: 45))
                        path.addLine(to: CGPoint(x: 200, y: 60))
                    }
                    .stroke(Color.red, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    
                    // Market demand line (variable trend)
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 40))
                        path.addLine(to: CGPoint(x: 100, y: 35))
                        path.addLine(to: CGPoint(x: 200, y: 45))
                    }
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                }
                .frame(height: 60)
                
                // Legend
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .scaleEffect(1.0)
                        Text("Depreciation")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .scaleEffect(1.0)
                        Text("Market Demand")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .padding(8)
        }
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