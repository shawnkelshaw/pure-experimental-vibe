import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    let email: String
    let firstName: String
    let lastName: String
    let displayName: String?
    let createdAt: Date

    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var preferredDisplayName: String {
        displayName ?? fullName
    }
    
    // Custom coding keys to match Supabase column names
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case displayName = "display_name"
        case createdAt = "created_at"
    }
}
