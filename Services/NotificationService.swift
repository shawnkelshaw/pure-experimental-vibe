import Foundation
import SwiftUI

class NotificationService: ObservableObject {
    @Published var showingNotification = false
    @Published var currentNotification: PendingNotification?
    
    init() {
        // Initialize notification service
    }
    
    func createNotification(_ notification: PendingNotification) async {
        await MainActor.run {
            self.currentNotification = notification
        }
    }
    
    func showNotification(_ notification: PendingNotification) async {
        await MainActor.run {
            self.currentNotification = notification
            self.showingNotification = true
        }
    }
    
    func confirmNotification(_ notification: PendingNotification) async {
        await MainActor.run {
            self.showingNotification = false
            self.currentNotification = nil
        }
    }
    
    func dismissNotification(_ notification: PendingNotification) async {
        await MainActor.run {
            self.showingNotification = false
            self.currentNotification = nil
        }
    }
}



