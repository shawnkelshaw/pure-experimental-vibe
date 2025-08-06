import SwiftUI

struct MarketView: View {
    @EnvironmentObject var garageViewModel: GarageViewModel
    @State private var dealershipAnnouncements: [DealershipAnnouncement] = []
    @State private var resaleValues: [VehicleResaleValue] = []
    @State private var currentCardIndex = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if garageViewModel.vehiclePassports.isEmpty {
                        // STATE 1: No passports - Show dealership announcements
                        ForEach(dealershipAnnouncements) { announcement in
                            DealershipAnnouncementCard(announcement: announcement)
                                .padding(.horizontal, 20)
                        }
                    } else {
                        // STATE 2: Has passports - Show resale value cards
                        if !resaleValues.isEmpty {
                            TabView(selection: $currentCardIndex) {
                                ForEach(Array(resaleValues.enumerated()), id: \.offset) { index, resaleValue in
                                    ResaleValueCard(resaleValue: resaleValue)
                                        .padding(.horizontal, 20)
                                        .tag(index)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .frame(height: 480)
                            
                            // Card indicator - single set below cards
                            if resaleValues.count > 1 {
                                HStack(spacing: 8) {
                                    ForEach(0..<resaleValues.count, id: \.self) { index in
                                        Circle()
                                            .fill(index == currentCardIndex ? Color.white : Color.gray.opacity(0.5))
                                            .frame(width: 8, height: 8)
                                    }
                                }
                                .padding(.top, 15)
                            }
                        } else {
                            // Loading state for resale values
                            VStack(spacing: 16) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.2)
                                
                                Text("Loading market data...")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            .frame(height: 200)
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color.appBackground)
            .navigationTitle("Market")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !garageViewModel.vehiclePassports.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "car.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.textPrimary)
                            
                            Text("\(garageViewModel.vehiclePassports.count)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textPrimary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.regularMaterial)
                        .clipShape(Capsule())
                    }
                }
            }
            .onAppear {
                loadMarketData()
            }
            .onChange(of: garageViewModel.vehiclePassports) { oldValue, newValue in
                loadMarketData()
            }
            // Remove forced color scheme - let system handle theme adaptation
        }
    }
    
    private func loadMarketData() {
        if garageViewModel.vehiclePassports.isEmpty {
            // Load dealership announcements for State 1
            dealershipAnnouncements = MarketDataService.shared.generateMockDealershipAnnouncements()
            resaleValues = []
        } else {
            // Load resale values for State 2
            dealershipAnnouncements = []
            resaleValues = garageViewModel.vehiclePassports.map { passport in
                MarketDataService.shared.generateMockResaleValue(for: passport)
            }
        }
    }
}

// MARK: - Dealership Announcement Card (State 1)
struct DealershipAnnouncementCard: View {
    let announcement: DealershipAnnouncement
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(announcement.dealershipName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(announcement.locationString)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "building.2")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.secondary)
                }
                
                // Vehicle & Pricing Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(announcement.vehicleDisplayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(announcement.formattedOriginalPrice)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                            .strikethrough()
                        
                        Text(announcement.formattedFinalPrice)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(announcement.formattedDiscount)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                
                // Action Button
                HStack {
                    Spacer()
                    
                    Button(action: {}) {
                        Text("View Offers")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.regularMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Resale Value Card (State 2)
struct ResaleValueCard: View {
    let resaleValue: VehicleResaleValue
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
            
            VStack(spacing: 20) {
                // Vehicle Info Header - placeholder since we don't have vehicle passport reference
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Vehicle")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Your Vehicle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "car.fill")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(.secondary)
                }
                
                // Resale Value Display
                VStack(spacing: 12) {
                    Text("Current Market Value")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(resaleValue.formattedCurrentValue)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: resaleValue.trendDirection.iconName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(resaleValue.trendDirection.color)
                        
                        Text(resaleValue.formattedTrendPercentage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(resaleValue.trendDirection.color)
                        
                        Text("projected")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Market Insights
                VStack(alignment: .leading, spacing: 8) {
                    Text("Market Insights")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Mileage Impact")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(String(format: "%.1f%%", resaleValue.mileageImpact * 100))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textPrimary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Age Impact")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(String(format: "%.1f%%", resaleValue.ageImpact * 100))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Text("Sell Now")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Button(action: {}) {
                        Text("Get Quote")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.regularMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(24)
        }
    }
}

struct MarketView_Previews: PreviewProvider {
    static var previews: some View {
        let authService = AuthService(isPreview: true)
        let garageViewModel = GarageViewModel(authService: authService)
        
        MarketView()
            .environmentObject(garageViewModel)
            .previewDisplayName("Market View - Native iOS Controls")
    }
}