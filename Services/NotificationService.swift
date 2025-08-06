import Foundation
import Supabase
import SwiftUI

// MARK: - NotificationCenter Extensions
extension Notification.Name {
    static let bluetoothPassportAccepted = Notification.Name("bluetoothPassportAccepted")
}

@MainActor
class NotificationService: ObservableObject {
    @Published var pendingNotifications: [PendingNotification] = []
    @Published var showingNotification = false
    @Published var currentNotification: PendingNotification? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // Track if bluetooth notification was dismissed (not accepted)
    @Published var bluetoothNotificationDismissed = false
    
    private let supabase = SupabaseConfig.shared.client
    
    // MARK: - Notification Management
    
    func checkForPendingNotifications(userId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [PendingNotification] = try await supabase
                .from("pending_notifications")
                .select()
                .eq("user_id", value: userId.uuidString)
                .eq("is_dismissed", value: false)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            pendingNotifications = response
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("Error fetching notifications: \(error)")
        }
    }
    
    func createNotification(_ notification: PendingNotification) async {
        do {
            let response: [PendingNotification] = try await supabase
                .from("pending_notifications")
                .insert(notification)
                .select()
                .execute()
                .value
            
            if let createdNotification = response.first {
                pendingNotifications.insert(createdNotification, at: 0)
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error creating notification: \(error)")
        }
    }
    
    func markAsRead(_ notification: PendingNotification) async {
        do {
            try await supabase
                .from("pending_notifications")
                .update(["is_read": true])
                .eq("id", value: notification.id.uuidString)
                .execute()
            
            // Update local state
            if let index = pendingNotifications.firstIndex(where: { $0.id == notification.id }) {
                let updatedNotification = pendingNotifications[index]
                pendingNotifications[index] = PendingNotification(
                    id: updatedNotification.id,
                    userId: updatedNotification.userId,
                    type: updatedNotification.type,
                    title: updatedNotification.title,
                    message: updatedNotification.message,
                    metadata: updatedNotification.metadata,
                    isRead: true,
                    isDismissed: updatedNotification.isDismissed,
                    scheduledFor: updatedNotification.scheduledFor,
                    createdAt: updatedNotification.createdAt,
                    updatedAt: Date()
                )
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error marking notification as read: \(error)")
        }
    }
    
    func dismissNotification(_ notification: PendingNotification) async {
        print("🚫 User DISMISSED notification: \(notification.type.displayName)")
        
        // Track bluetooth notification dismissal so it can re-trigger
        if notification.type == .bluetoothPassportPush {
            bluetoothNotificationDismissed = true
            print("🚫 Bluetooth notification marked as dismissed - will re-trigger on next visit")
        }
        
        do {
            try await supabase
                .from("pending_notifications")
                .update(["is_dismissed": true])
                .eq("id", value: notification.id.uuidString)
                .execute()
            
            // Remove from local state
            pendingNotifications.removeAll { $0.id == notification.id }
            
            // Hide notification if it's currently showing
            if currentNotification?.id == notification.id {
                hideNotification()
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error dismissing notification: \(error)")
        }
    }
    
    func deleteNotification(_ notification: PendingNotification) async {
        do {
            try await supabase
                .from("pending_notifications")
                .delete()
                .eq("id", value: notification.id.uuidString)
                .execute()
            
            // Remove from local state
            pendingNotifications.removeAll { $0.id == notification.id }
            
            // Hide notification if it's currently showing
            if currentNotification?.id == notification.id {
                hideNotification()
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error deleting notification: \(error)")
        }
    }
    
    // MARK: - UI Management
    
    func showNotification(_ notification: PendingNotification) {
        print("📱 showNotification called with notification ID: \(notification.id)")
        print("📱 Setting currentNotification and showingNotification = true")
        currentNotification = notification
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showingNotification = true
        }
        print("📱 showingNotification is now: \(showingNotification)")
        print("📱 currentNotification is: \(currentNotification?.title ?? "nil")")
    }
    
    func hideNotification() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showingNotification = false
        }
        
        // Clear current notification after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.currentNotification = nil
        }
    }
    
    func confirmNotification(_ notification: PendingNotification) async {
        print("✅ User ACCEPTED notification: \(notification.type.displayName)")
        
        // Reset dismissal tracking when user accepts
        if notification.type == .bluetoothPassportPush {
            bluetoothNotificationDismissed = false
            print("✅ Bluetooth notification accepted - dismissal tracking reset")
        }
        
        await markAsRead(notification)
        hideNotification()
        
        // Handle notification-specific actions
        switch notification.type {
        case .bluetoothPassportPush:
            await handleBluetoothPassportConfirmation(notification)
        case .maintenanceReminder:
            await handleMaintenanceReminderConfirmation(notification)
        default:
            break
        }
    }
    
    // MARK: - Bluetooth Passport Specific
    
    func triggerBluetoothPassportNotification(userId: UUID, vehicleName: String? = nil, delay: TimeInterval = 3.0) {
        print("📱 NotificationService: triggerBluetoothPassportNotification called")
        print("📱 User ID: \(userId)")
        print("📱 Vehicle name: \(vehicleName ?? "nil")")
        print("📱 Delay: \(delay) seconds")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            print("📱 Timer fired! Creating notification...")
            Task {
                let notification = PendingNotification.bluetoothPassportPush(
                    userId: userId,
                    vehicleName: vehicleName
                )
                
                print("📱 Created notification: \(notification.id)")
                await self.createNotification(notification)
                print("📱 Calling showNotification...")
                self.showNotification(notification)
                print("📱 showingNotification is now: \(self.showingNotification)")
            }
        }
    }
    
    private func handleBluetoothPassportConfirmation(_ notification: PendingNotification) async {
        print("🔔 Bluetooth passport confirmed for notification: \(notification.id)")
        
        // Post notification that passport was accepted so GarageViewModel can handle it
        NotificationCenter.default.post(
            name: .bluetoothPassportAccepted,
            object: nil,
            userInfo: [
                "notification": notification,
                "senderName": notification.metadata?["sender_name"] ?? "Unknown Sender"
            ]
        )
        
        await dismissNotification(notification)
    }
    
    private func handleMaintenanceReminderConfirmation(_ notification: PendingNotification) async {
        // This could navigate to maintenance view or create a reminder
        print("Maintenance reminder confirmed for notification: \(notification.id)")
        await dismissNotification(notification)
    }
    
    // MARK: - Computed Properties
    
    var unreadNotificationsCount: Int {
        pendingNotifications.filter { !$0.isRead }.count
    }
    
    var hasUnreadNotifications: Bool {
        unreadNotificationsCount > 0
    }
    
    var bluetoothNotifications: [PendingNotification] {
        pendingNotifications.filter { $0.type == .bluetoothPassportPush }
    }
    
    var maintenanceNotifications: [PendingNotification] {
        pendingNotifications.filter { $0.type == .maintenanceReminder }
    }
} 