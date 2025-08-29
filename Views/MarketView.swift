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
    @EnvironmentObject var appointmentService: AppointmentService
    @State private var currentZipCode = "31405"
    @State private var isEditingZipCode = false
    @State private var tempZipCode = ""
    @State private var isLoading = true
    @FocusState private var isZipCodeFocused: Bool
    
    // Dealer Trade-In Flow States
    @State private var isRetrievingDealerAgent = false
    @State private var foundDealerAgent: DealerAgent?
    @State private var showDealerConfirmation = false
    @State private var selectedVehicle: Vehicle?
    @State private var selectedPassport: VehiclePassport?
    
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
                        
                        HStack {
                            if isEditingZipCode {
                                TextField("Enter zip code", text: $tempZipCode)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .keyboardType(.numberPad)
                                    .focused($isZipCodeFocused)
                                    .onSubmit {
                                        saveZipCode()
                                    }
                            } else {
                                Text(currentZipCode)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                            
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
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if !isEditingZipCode {
                                tempZipCode = currentZipCode
                                isEditingZipCode = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isZipCodeFocused = true
                                }
                            }
                        }
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
                                .padding(.top, .tight)
                            
                            // Conditional: Full-width for single passport, carousel for multiple
                            if garageViewModel.vehiclePassports.count == 1 {
                                // Single passport - full width (any device)
                                ForEach(Array(zip(garageViewModel.vehiclePassports, garageViewModel.vehicles)), id: \.0.id) { passport, vehicle in
                                    PassportChartCard(
                                        passport: passport, 
                                        vehicle: vehicle,
                                        onDealerTradeIn: startDealerAgentRetrieval(for:passport:)
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
                                                vehicle: vehicle,
                                                onDealerTradeIn: startDealerAgentRetrieval(for:passport:)
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
            .onChange(of: isZipCodeFocused) { focused in
                if !focused && isEditingZipCode {
                    // User tapped outside or dismissed keyboard
                    cancelZipCodeEdit()
                }
            }
            .onAppear {
                // Simulate loading delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isLoading = false
                    }
                }
            }
            .alert("Dealer agent found", isPresented: $showDealerConfirmation) {
                Button("I'm not ready", role: .cancel) {
                    // Handle NO - dismiss
                    foundDealerAgent = nil
                }
                Button("Search for agents") {
                    // TODO: Implement different agent selection flow
                    foundDealerAgent = nil
                }
                Button("Yes, schedule appointment") {
                    // Handle YES - schedule appointment
                    handleScheduleAppointment()
                }
            } message: {
                if let agent = foundDealerAgent {
                    Text(formatDealerAgentMessage(agent: agent))
                }
            }
            .overlay {
                if isRetrievingDealerAgent {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.white)
                        
                        Text("Retrieving dealer agent...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(24)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func saveZipCode() {
        currentZipCode = tempZipCode
        isEditingZipCode = false
        isZipCodeFocused = false
    }
    
    private func cancelZipCodeEdit() {
        tempZipCode = currentZipCode
        isEditingZipCode = false
        isZipCodeFocused = false
    }
    
    // MARK: - Dealer Trade-In Flow
    
    private func startDealerAgentRetrieval(for vehicle: Vehicle, passport: VehiclePassport) {
        selectedVehicle = vehicle
        selectedPassport = passport
        isRetrievingDealerAgent = true
        
        // Simulate 4-6 second retrieval delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 4.0...6.0)) {
            foundDealerAgent = DealerAgent.alanSubran
            isRetrievingDealerAgent = false
            showDealerConfirmation = true
        }
    }
    
    private func handleScheduleAppointment() {
        // Package vehicle data for Voiceflow integration
        let vehicleContext = prepareVehicleContext()
        
        // Create appointment with dealer agent
        if let vehicle = selectedVehicle, let agent = foundDealerAgent {
            let vehicleInfo = "\(vehicle.year) \(vehicle.make) \(vehicle.model)"
            appointmentService.scheduleAppointment(
                vehicleInfo: vehicleInfo,
                dealerAgent: agent
            )
        }
        
        // Clear current state
        foundDealerAgent = nil
        selectedVehicle = nil
        selectedPassport = nil
        
        // TODO: This is where we'll launch Voiceflow integration with vehicle context
        // For now, just show a temporary success alert
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("Appointment scheduling would start here with Voiceflow")
            print("Vehicle Context: \(vehicleContext)")
        }
    }
    
    private func formatDealerAgentMessage(agent: DealerAgent) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        let formattedDate = dateFormatter.string(from: agent.lastInteractionDate)
        
        return """
        The last dealer agent you interacted with was:
        
        \(agent.name)
        \(agent.dealership)
        \(formattedDate)
        
        I can help schedule an appointment with \(agent.name) if you're ready to proceed.
        """
    }
    
    private func prepareVehicleContext() -> [String: Any] {
        guard let vehicle = selectedVehicle, let passport = selectedPassport else {
            return [:]
        }
        
        return [
            "vehicle_year": vehicle.year,
            "vehicle_make": vehicle.make,
            "vehicle_model": vehicle.model,
            "vehicle_vin": vehicle.vin ?? "Unknown",
            "vehicle_mileage": vehicle.mileage ?? 0,
            "vehicle_color": vehicle.color ?? "Unknown",
            "purchase_price": passport.purchasePrice ?? 0,
            "dealer_agent_name": foundDealerAgent?.name ?? "Alan Subran",
            "dealer_name": foundDealerAgent?.dealership ?? "Savannah Tesla",
            "user_zip_code": currentZipCode
        ]
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


// MARK: - Passport Chart Card

struct PassportChartCard: View {
    let passport: VehiclePassport
    let vehicle: Vehicle
    let onDealerTradeIn: (Vehicle, VehiclePassport) -> Void
    @EnvironmentObject var appointmentService: AppointmentService
    
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
                // Dealer Trade-In button: updates to scheduled state and disables when appointment exists
                Button(appointmentService.hasScheduledAppointment(for: vehicle) ? "TRADE IN APPOINTMENT SCHEDULED" : "DEALER TRADE IN") {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    // Start dealer agent retrieval simulation
                    onDealerTradeIn(vehicle, passport)
                }
                .buttonStyle(NativeButtonWithPressState())
                .disabled(appointmentService.hasScheduledAppointment(for: vehicle))
                .accessibilityLabel(appointmentService.hasScheduledAppointment(for: vehicle) ? "Trade in appointment scheduled" : "Dealer trade in")
                .accessibilityHint(appointmentService.hasScheduledAppointment(for: vehicle) ? "Appointment is already scheduled" : "Tap to trade in your vehicle at a dealer")
                
                Button("SELL NOW (DIRECT)") {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    // Placeholder action
                }
                .buttonStyle(NativeButtonWithPressState())
                .accessibilityLabel("Sell now direct")
                .accessibilityHint("Tap to sell your vehicle directly")
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

// MARK: - Native Button Style with Press State
struct NativeButtonWithPressState: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote)
            .fontWeight(.medium)
            .textCase(.uppercase)
            .foregroundColor(
                isEnabled
                ? (configuration.isPressed ? Color.accentColor : Color.secondary)
                : Color(.tertiaryLabel)
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, .tight)
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .stroke(
                        isEnabled
                        ? (configuration.isPressed ? Color.accentColor : Color(.tertiaryLabel))
                        : Color(.tertiaryLabel),
                        lineWidth: 0.5
                    )
            )
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
                ),
                onDealerTradeIn: { _, _ in print("Preview dealer trade-in") }
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
                ),
                onDealerTradeIn: { _, _ in print("Preview dealer trade-in") }
            )
            .frame(height: 400)
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}