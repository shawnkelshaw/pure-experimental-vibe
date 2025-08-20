import SwiftUI

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

struct MarketView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MarketView()
        }
    }
}