import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    
    // Name fields
    let firstName: String?
    let lastName: String?
    let displayName: String?
    
    // Contact information
    let phoneNumber: String?
    
    // Address fields
    let streetAddress: String?
    let city: String?
    let stateProvince: String?
    let postalCode: String?
    let country: String?
    
    // Profile
    let avatarUrl: String?
    
    // Notification preferences
    let notificationsEmail: Bool
    let notificationsPush: Bool
    let notificationsBluetooth: Bool
    let notificationsMarketing: Bool
    
    // Account metadata
    let isActive: Bool
    let lastLoginAt: Date?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case firstName = "first_name"
        case lastName = "last_name"
        case displayName = "display_name"
        case phoneNumber = "phone_number"
        case streetAddress = "street_address"
        case city
        case stateProvince = "state_province"
        case postalCode = "postal_code"
        case country
        case avatarUrl = "avatar_url"
        case notificationsEmail = "notifications_email"
        case notificationsPush = "notifications_push"
        case notificationsBluetooth = "notifications_bluetooth"
        case notificationsMarketing = "notifications_marketing"
        case isActive = "is_active"
        case lastLoginAt = "last_login_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var fullName: String {
        let first = firstName ?? ""
        let last = lastName ?? ""
        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
    }
    
    var preferredDisplayName: String {
        // Priority: display_name > full name > email
        if let displayName = displayName, !displayName.isEmpty {
            return displayName
        }
        if !fullName.isEmpty {
            return fullName
        }
        return email
    }
    
    var formattedAddress: String {
        var components: [String] = []
        
        if let street = streetAddress, !street.isEmpty {
            components.append(street)
        }
        
        var cityStateZip: [String] = []
        if let city = city, !city.isEmpty {
            cityStateZip.append(city)
        }
        if let state = stateProvince, !state.isEmpty {
            cityStateZip.append(state)
        }
        if let zip = postalCode, !zip.isEmpty {
            cityStateZip.append(zip)
        }
        
        if !cityStateZip.isEmpty {
            components.append(cityStateZip.joined(separator: ", "))
        }
        
        if let country = country, !country.isEmpty {
            components.append(country)
        }
        
        return components.joined(separator: "\n")
    }
    
    var hasCompleteProfile: Bool {
        return firstName != nil && 
               lastName != nil && 
               !fullName.isEmpty
    }
    
    var hasAddress: Bool {
        return streetAddress != nil || 
               city != nil || 
               stateProvince != nil || 
               postalCode != nil
    }
} 