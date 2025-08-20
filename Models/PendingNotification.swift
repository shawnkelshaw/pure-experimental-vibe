import Foundation

struct PendingNotification: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let type: NotificationType
    let title: String
    let message: String
    let metadata: [String: String]
    let isRead: Bool
    let isDismissed: Bool
    let scheduledFor: Date?
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        type: NotificationType,
        title: String,
        message: String,
        metadata: [String: String] = [:],
        isRead: Bool = false,
        isDismissed: Bool = false,
        scheduledFor: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.title = title
        self.message = message
        self.metadata = metadata
        self.isRead = isRead
        self.isDismissed = isDismissed
        self.scheduledFor = scheduledFor
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum NotificationType: String, CaseIterable, Codable {
    case bluetoothPassportPush = "bluetooth_passport_push"
    case qr = "qr"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .bluetoothPassportPush:
            return "Bluetooth Passport"
        case .qr:
            return "QR Code"
        case .system:
            return "System"
        }
    }
    
    var iconName: String {
        switch self {
        case .bluetoothPassportPush:
            return "magazine.fill"
        case .qr:
            return "qrcode"
        case .system:
            return "bell"
        }
    }
}
