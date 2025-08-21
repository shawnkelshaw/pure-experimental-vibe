import SwiftUI
import Charts
import UIKit // For haptic feedback

// MARK: - Custom RoundedCorner Shape
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct MarketView: View {
    @EnvironmentObject var garageViewModel: GarageViewModel
    @State private var currentZipCode = "31405"
    @State private var showingZipCodeSheet = false
    @State private var tempZipCode = ""
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                                LazyVStack(spacing: 24) {
                    // Zip Code Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CURRENT AREA")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .padding(.horizontal)
                        
                        Button(action: {
                            tempZipCode = currentZipCode
                            showingZipCodeSheet = true
                        }) {
                            HStack {
                                Text(currentZipCode)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "keyboard.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, .regular)
                            .padding(.vertical, .mediumTight)
                            .padding(.bottom, .tight)
                            .background(
                                VStack {
                                    Spacer()
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(Color(.tertiaryLabel))
                                }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }
                    
                    // Chart Carousel (only show when user has vehicle passports)
                    if !isLoading && garageViewModel.hasVehiclePassports {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("MY PASSPORT(S): DEMAND TRENDS FOR CURRENT AREA")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .padding(.horizontal)
                            
                            // Conditional: Full-width for single passport, carousel for multiple
                            if garageViewModel.vehiclePassports.count == 1 {
                                // Single passport - full width (any device)
                                ForEach(Array(zip(garageViewModel.vehiclePassports, garageViewModel.vehicles)), id: \.0.id) { passport, vehicle in
                                    PassportChartCard(
                                        passport: passport, 
                                        vehicle: vehicle
                                    )
                                }
                                .padding(.horizontal)
                            } else {
                                // Multiple passports - horizontal carousel
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(Array(zip(garageViewModel.vehiclePassports, garageViewModel.vehicles)), id: \.0.id) { passport, vehicle in
                                            PassportChartCard(
                                                passport: passport, 
                                                vehicle: vehicle
                                            )
                                        }
                                    }
                                    .padding(.leading, .regular)
                                }
                            }
                        }
                        .padding(.bottom, .loose) // Add extra spacing below chart carousel
                    }
                    
                    // Popular Vehicles Section
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MOST POPULAR VEHICLES IN CURRENT AREA")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .padding(.horizontal)
                        }
                        
                        if isLoading {
                            VStack(spacing: 0) {
                                ForEach(0..<5, id: \.self) { index in
                                    PopularVehicleSkeletonRow()
                                    
                                    if index < 4 {
                                        Divider()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(mockPopularVehicles.indices, id: \.self) { index in
                                    PopularVehicleRow(vehicle: mockPopularVehicles[index])
                                    
                                    if index < mockPopularVehicles.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                                        // Dealership Announcements Section
                    VStack(alignment: .leading, spacing: 16) {
                        Divider()
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DEALERSHIP ANNOUNCEMENTS IN CURRENT AREA")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .padding(.horizontal)
                        }
                        
                        if isLoading {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(0..<3, id: \.self) { _ in
                                        DealershipAnnouncementSkeletonCard()
                                    }
                                }
                                .padding(.leading, .regular) // Only left padding for first card
                            }
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(mockDealershipAnnouncements, id: \.id) { announcement in
                                        DealershipAnnouncementCard(announcement: announcement)
                                    }
                                }
                                .padding(.leading, .regular) // Only left padding for first card
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Market")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingZipCodeSheet) {
                ZipCodeInputSheet(
                    zipCode: $tempZipCode,
                    isPresented: $showingZipCodeSheet,
                    onSave: {
                        currentZipCode = tempZipCode
                    }
                )
            }
            .onAppear {
                // Simulate loading delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isLoading = false
                    }
                }
            }
        }
    }
    
    // MARK: - Mock Data
    
    private var mockPopularVehicles: [PopularVehicle] {
        [
            PopularVehicle(
                make: "Tesla",
                model: "Model Y",
                year: 2024,
                averagePrice: 52000,
                popularityRank: 1,
                valuationChange: 2.5
            ),
            PopularVehicle(
                make: "BMW",
                model: "X3",
                year: 2024,
                averagePrice: 48500,
                popularityRank: 2,
                valuationChange: -1.2
            ),
            PopularVehicle(
                make: "Mercedes-Benz",
                model: "C-Class",
                year: 2024,
                averagePrice: 45000,
                popularityRank: 3,
                valuationChange: 0.8
            ),
            PopularVehicle(
                make: "Audi",
                model: "Q5",
                year: 2024,
                averagePrice: 46800,
                popularityRank: 4,
                valuationChange: 1.5
            ),
            PopularVehicle(
                make: "Lexus",
                model: "RX",
                year: 2024,
                averagePrice: 50200,
                popularityRank: 5,
                valuationChange: -0.3
            )
        ]
    }
    
    private var mockDealershipAnnouncements: [DealershipAnnouncement] {
        MarketDataService.shared.generateMockDealershipAnnouncements().prefix(3).map { $0 }
    }
}

// MARK: - Data Models

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let month: String
    let value: Double
    let passportId: UUID
}

struct PopularVehicle {
    let make: String
    let model: String
    let year: Int
    let averagePrice: Int
    let popularityRank: Int
    let valuationChange: Double // percentage change over 3 months
    
    var displayName: String {
        "\(year) \(make) \(model)"
    }
    
    var formattedPrice: String {
        "$\(averagePrice.formatted(.number.grouping(.automatic)))"
    }
    
    var formattedValuationChange: String {
        let sign = valuationChange >= 0 ? "+" : ""
        return "\(sign)\(valuationChange.formatted(.number.precision(.fractionLength(1))))%"
    }
    
    var valuationColor: Color {
        if valuationChange > 0 {
            return Color(.systemGreen)
        } else if valuationChange < 0 {
            return Color(.systemRed)
        } else {
            return Color(.systemGray)
        }
    }
}



// MARK: - View Components

struct PopularVehicleRow: View {
    let vehicle: PopularVehicle
    
    var body: some View {
        HStack(spacing: 16) {
            // Vehicle info
            VStack(alignment: .leading, spacing: 4) {
                Text(vehicle.displayName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("3 mos valuation forecast")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Price and valuation
            VStack(alignment: .trailing, spacing: 4) {
                Text(vehicle.formattedPrice)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(vehicle.formattedValuationChange)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(vehicle.valuationColor)
            }
        }
        .padding(.vertical, .mediumTight)
        .contentShape(Rectangle())
    }
}

struct DealershipAnnouncementCard: View {
    let announcement: DealershipAnnouncement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Placeholder image - flush to card edges, no rounded corners
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 120)
                .overlay(
                    Image(systemName: "car")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                )
            
            // Content with left/right padding using system spacing
            VStack(alignment: .leading, spacing: 8) {
                Text(announcement.vehicleDisplayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(announcement.formattedDiscount)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color(.systemGreen))
                
                Text(announcement.dealershipName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(announcement.locationString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, .regular) // Using SystemSpacing.swift value (16pt)
            .padding(.bottom, .regular) // Add bottom padding (16pt)
        }
        .frame(width: 240)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .stroke(Color(.tertiaryLabel), lineWidth: 0.5) // Faint semantic border
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Skeleton Loading Components

struct PopularVehicleSkeletonRow: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Skeleton rank indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: 32, height: 20)
            
            // Skeleton vehicle info
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 120, height: 16)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(width: 80, height: 12)
            }
            
            Spacer()
            
            // Skeleton price and valuation
            VStack(alignment: .trailing, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 16)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(width: 40, height: 12)
            }
        }
        .padding(.vertical, .mediumTight)
        .opacity(isAnimating ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

struct DealershipAnnouncementSkeletonCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Skeleton image - flush to card edges, no rounded corners
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 120)
            
            // Skeleton content with left/right padding using system spacing
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 18)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(width: 80, height: 12)
            }
            .padding(.horizontal, .regular) // Using SystemSpacing.swift value (16pt)
            .padding(.bottom, .regular) // Add bottom padding (16pt)
        }
        .frame(width: 240)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .stroke(Color(.tertiaryLabel), lineWidth: 0.5) // Faint semantic border
        )
        .opacity(isAnimating ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Zip Code Input Sheet

struct ZipCodeInputSheet: View {
    @Binding var zipCode: String
    @Binding var isPresented: Bool
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("YOUR CURRENT AREA")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    TextField("Enter zip code", text: $zipCode)
                        .keyboardType(.numberPad)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 150)
                        .padding(.bottom, .tight)
                        .background(
                            VStack {
                                Spacer()
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.secondary)
                            }
                        )
                }
                
                Spacer()
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onSave()
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                    .disabled(zipCode.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Passport Chart Card

struct PassportChartCard: View {
    let passport: VehiclePassport
    let vehicle: Vehicle
    @State private var isSellButtonPressed = false
    @State private var isTradeInButtonPressed = false
    
    // Generate mock 3-month forecast data
    private var chartData: [ChartDataPoint] {
        let purchasePrice = Double(passport.purchasePrice ?? 50000) // Default to $50k if nil
        let months = ["Jul", "Aug", "Sep"]
        
        // Generate trend: slight increase or decrease based on passport ID
        let trend = passport.id.uuidString.hashValue % 2 == 0 ? 1.0 : -1.0
        let monthlyChange = purchasePrice * 0.02 * trend // 2% change per month
        
        return months.enumerated().map { index, month in
            let monthValue = purchasePrice + (monthlyChange * Double(index + 1))
            return ChartDataPoint(month: month, value: monthValue, passportId: passport.id)
        }
    }
    

    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Vehicle info above chart (Year, Make, Model)
            VStack(alignment: .leading, spacing: 8) {
                Text("\(String(vehicle.year)) \(vehicle.make) - \(vehicle.model)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                // VIN below the title
                Text("VIN: \(vehicle.vin ?? "Unknown")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, .regular)
            .padding(.bottom, .tight)
            
            // Swift Chart
            Chart(chartData) { dataPoint in
                LineMark(
                    x: .value("Month", dataPoint.month),
                    y: .value("Value", dataPoint.value)
                )
                .foregroundStyle(passport.id.uuidString.hashValue % 2 == 0 ? Color(.systemGreen) : Color(.systemRed))
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                PointMark(
                    x: .value("Month", dataPoint.month),
                    y: .value("Value", dataPoint.value)
                )
                .foregroundStyle(passport.id.uuidString.hashValue % 2 == 0 ? Color(.systemGreen) : Color(.systemRed))
            }
            .frame(height: 250) // Increased height to prevent cutoff
            .chartYScale(domain: .automatic(includesZero: false))
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    if let doubleValue = value.as(Double.self) {
                        AxisValueLabel {
                            Text("$\(Int(doubleValue/1000))k") // Abbreviated format: $47k
                        }
                    }
                }
            }
            
            // Action buttons below chart
            VStack(spacing: .tight) {
                Button(action: {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    // Placeholder action
                }) {
                    Text("SELL NOW (DIRECT)")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, .tight)
                        .background(Color(.systemBackground).opacity(isSellButtonPressed ? 0.8 : 1.0))
                        .overlay(
                            Rectangle()
                                .stroke(Color(.tertiaryLabel).opacity(isSellButtonPressed ? 0.6 : 1.0), lineWidth: 0.5)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isSellButtonPressed ? 0.98 : 1.0)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isSellButtonPressed = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isSellButtonPressed = false
                        }
                    }
                }
                .accessibilityLabel("Sell now direct")
                .accessibilityHint("Tap to sell your vehicle directly")
                
                Button(action: {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    // Placeholder action
                }) {
                    Text("DEALER TRADE IN")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, .tight)
                        .background(Color(.systemBackground).opacity(isTradeInButtonPressed ? 0.8 : 1.0))
                        .overlay(
                            Rectangle()
                                .stroke(Color(.tertiaryLabel).opacity(isTradeInButtonPressed ? 0.6 : 1.0), lineWidth: 0.5)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isTradeInButtonPressed ? 0.98 : 1.0)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isTradeInButtonPressed = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isTradeInButtonPressed = false
                        }
                    }
                }
                .accessibilityLabel("Dealer trade in")
                .accessibilityHint("Tap to trade in your vehicle at a dealer")
            }
        }
        .frame(minWidth: 280, maxWidth: .infinity)
        .padding(.top, .regular)
        .padding(.bottom, .regular)
        .padding(.leading, .regular)
        .padding(.trailing, .regular)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .stroke(Color(.tertiaryLabel), lineWidth: 0.5)
        )
    }
}

// MARK: - Custom Button Style for Chart Cards
struct ChartButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Color(.systemBackground)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .overlay(
                Rectangle()
                    .stroke(
                        Color(.tertiaryLabel)
                            .opacity(configuration.isPressed ? 0.6 : 1.0),
                        lineWidth: 0.5
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct MarketView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MarketView()
                .environmentObject(GarageViewModel(authService: AuthService()))
        }
    }
}

// MARK: - PassportChartCard Preview
struct PassportChartCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            // Preview with single passport (tablet mode)
            PassportChartCard(
                passport: VehiclePassport(vehicleId: UUID()),
                vehicle: Vehicle(
                    id: UUID(),
                    make: "Tesla",
                    model: "Model 3",
                    year: 2023,
                    vin: "5YJ3E1EA1KF123456",
                    licensePlate: "TESLA123",
                    mileage: 15000,
                    fuelType: .electric,
                    transmission: .automatic,
                    color: "Pearl White",
                    engineSize: "Electric Motor"
                )
            )
            .frame(height: 400)
            .padding()
            
            // Preview with multiple passports (phone mode)
            PassportChartCard(
                passport: VehiclePassport(vehicleId: UUID()),
                vehicle: Vehicle(
                    id: UUID(),
                    make: "BMW",
                    model: "M3",
                    year: 2022,
                    vin: "WBS3R9C00NP123456",
                    licensePlate: "BMW-M3X",
                    mileage: 8500,
                    fuelType: .gasoline,
                    transmission: .automatic,
                    color: "Alpine White",
                    engineSize: "3.0L Twin Turbo"
                )
            )
            .frame(height: 400)
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}