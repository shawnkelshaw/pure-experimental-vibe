import Foundation

struct DealerAgent: Identifiable, Codable {
    let id: UUID
    let name: String
    let dealership: String
    let phone: String
    let email: String
    let specialties: [String]
    let rating: Double
    let yearsExperience: Int
    let profileImageUrl: String?
    let isAvailable: Bool
    let workingHours: String
    let lastInteractionDate: Date
    let createdAt: Date
    let updatedAt: Date
    
    var displayName: String {
        name
    }
    
    var displayDealership: String {
        dealership
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        dealership: String,
        phone: String,
        email: String,
        specialties: [String] = [],
        rating: Double = 5.0,
        yearsExperience: Int = 5,
        profileImageUrl: String? = nil,
        isAvailable: Bool = true,
        workingHours: String = "9:00 AM - 6:00 PM",
        lastInteractionDate: Date = Date().addingTimeInterval(-86400 * 12), // 12 days ago
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.dealership = dealership
        self.phone = phone
        self.email = email
        self.specialties = specialties
        self.rating = rating
        self.yearsExperience = yearsExperience
        self.profileImageUrl = profileImageUrl
        self.isAvailable = isAvailable
        self.workingHours = workingHours
        self.lastInteractionDate = lastInteractionDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Mock Data
    
    static let alanSubran = DealerAgent(
        name: "Alan Subran",
        dealership: "Savannah Tesla",
        phone: "(912) 555-0123",
        email: "alan.subran@savannahtesla.com",
        specialties: ["Tesla Vehicles", "Electric Vehicle Trade-ins", "Model Y Specialist"],
        rating: 4.9,
        yearsExperience: 8,
        isAvailable: true,
        workingHours: "8:00 AM - 7:00 PM",
        lastInteractionDate: Calendar.current.date(byAdding: .day, value: -12, to: Date()) ?? Date()
    )
    
    // Additional mock agents for variety
    static let mockAgents = [
        alanSubran,
        DealerAgent(
            name: "Sarah Chen",
            dealership: "Savannah Tesla",
            phone: "(912) 555-0124",
            email: "sarah.chen@savannahtesla.com",
            specialties: ["Model S", "Model 3", "Luxury Vehicle Trade-ins"],
            rating: 4.8,
            yearsExperience: 6,
            isAvailable: true
        ),
        DealerAgent(
            name: "Marcus Johnson",
            dealership: "Savannah Tesla",
            phone: "(912) 555-0125",
            email: "marcus.johnson@savannahtesla.com",
            specialties: ["Model X", "Commercial Vehicles", "Fleet Sales"],
            rating: 4.7,
            yearsExperience: 12,
            isAvailable: false,
            workingHours: "10:00 AM - 5:00 PM"
        )
    ]
    
    // MARK: - Coding Keys for potential future Supabase integration
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case dealership
        case phone
        case email
        case specialties
        case rating
        case yearsExperience = "years_experience"
        case profileImageUrl = "profile_image_url"
        case isAvailable = "is_available"
        case workingHours = "working_hours"
        case lastInteractionDate = "last_interaction_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
