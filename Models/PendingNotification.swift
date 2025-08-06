import Foundation

struct PendingNotification: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let type: NotificationType
    let title: String
    let message: String
    let metadata: [String: String]?
    let isRead: Bool
    let isDismissed: Bool
    let scheduledFor: Date?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type, title, message, metadata
        case isRead = "is_read"
        case isDismissed = "is_dismissed"
        case scheduledFor = "scheduled_for"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum NotificationType: String, Codable, CaseIterable {
    case bluetoothPassportPush = "bluetooth_passport_push"
    case maintenanceReminder = "maintenance_reminder"
    case documentExpiry = "document_expiry"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .bluetoothPassportPush: return "Vehicle Passport Push"
        case .maintenanceReminder: return "Maintenance Reminder"
        case .documentExpiry: return "Document Expiry"
        case .other: return "Other"
        }
    }
    
    var iconName: String {
        switch self {
        case .bluetoothPassportPush: return "antenna.radiowaves.left.and.right"
        case .maintenanceReminder: return "wrench.and.screwdriver"
        case .documentExpiry: return "doc.badge.clock"
        case .other: return "bell"
        }
    }
    
    var defaultTitle: String {
        switch self {
        case .bluetoothPassportPush: return "Vehicle Passport Incoming"
        case .maintenanceReminder: return "Maintenance Due"
        case .documentExpiry: return "Document Expiring"
        case .other: return "Notification"
        }
    }
}

// MARK: - Notification Creation Helpers
extension PendingNotification {
    static func bluetoothPassportPush(userId: UUID, vehicleName: String? = nil) -> PendingNotification {
        let senderName = vehicleName ?? "Alan Subran"
        return PendingNotification(
            id: UUID(),
            userId: userId,
            type: .bluetoothPassportPush,
            title: "Vehicle Passport Incoming",
            message: "\(senderName) is sending you a Vehicle Passport—a digital certificate for your vehicle that can help speed up future trade-ins.",
            metadata: vehicleName != nil ? ["sender_name": vehicleName!] : nil,
            isRead: false,
            isDismissed: false,
            scheduledFor: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    static func maintenanceReminder(userId: UUID, vehicleName: String, serviceType: String, dueDate: Date? = nil) -> PendingNotification {
        let dueDateText = dueDate != nil ? DateFormatter.shortDate.string(from: dueDate!) : "soon"
        return PendingNotification(
            id: UUID(),
            userId: userId,
            type: .maintenanceReminder,
            title: "Maintenance Due",
            message: "\(serviceType) is due for \(vehicleName) \(dueDateText).",
            metadata: [
                "vehicle_name": vehicleName,
                "service_type": serviceType,
                "due_date": dueDateText
            ],
            isRead: false,
            isDismissed: false,
            scheduledFor: dueDate,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
} 