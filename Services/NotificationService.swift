import Foundation
import SwiftUI

@MainActor
class NotificationService: ObservableObject {
    @Published var showingNotification = false
    @Published var currentNotification: PendingNotification?
    
    init() {
        // Initialize notification service
    }
    
    func createNotification(_ notification: PendingNotification) {
        self.currentNotification = notification
    }
    
    func showNotification(_ notification: PendingNotification) {
        self.currentNotification = notification
        self.showingNotification = true
    }
    
    func confirmNotification(_ notification: PendingNotification) {
        self.showingNotification = false
        self.currentNotification = nil
    }
    
    func dismissNotification(_ notification: PendingNotification) {
        self.showingNotification = false
        self.currentNotification = nil
    }
}



