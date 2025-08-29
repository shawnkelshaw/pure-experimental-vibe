import Foundation
import SwiftUI

@MainActor
class AppointmentService: ObservableObject {
    @Published var hasUpcomingAppointments = false
    @Published var upcomingAppointments: [Appointment] = []
    
    func clearAllAppointments() {
        upcomingAppointments.removeAll()
        hasUpcomingAppointments = false
    }
    
    func scheduleAppointment(
        vehicleInfo: String,
        dealerAgent: DealerAgent,
        scheduledDate: Date = Date().addingTimeInterval(86400) // Default to tomorrow
    ) {
        let appointment = Appointment(
            id: UUID(),
            vehicleInfo: vehicleInfo,
            dealerAgent: dealerAgent,
            scheduledDate: scheduledDate,
            status: AppointmentStatus.scheduled
        )
        
        upcomingAppointments.append(appointment)
        hasUpcomingAppointments = true
    }
    
    func markAppointmentCompleted(_ appointmentId: UUID) {
        if let index = upcomingAppointments.firstIndex(where: { $0.id == appointmentId }) {
            upcomingAppointments[index].status = .completed
        }
        updateNotificationBadge()
    }
    
    func cancelAppointment(_ appointmentId: UUID) {
        upcomingAppointments.removeAll { $0.id == appointmentId }
        updateNotificationBadge()
    }
    
    // Lightweight helper to check if there's a scheduled appointment for a specific vehicle
    func hasScheduledAppointment(for vehicle: Vehicle) -> Bool {
        upcomingAppointments.contains { appt in
            appt.status == .scheduled
            && appt.vehicleInfo.contains(vehicle.make)
            && appt.vehicleInfo.contains(vehicle.model)
            && appt.vehicleInfo.contains(String(vehicle.year))
        }
    }
    
    private func updateNotificationBadge() {
        hasUpcomingAppointments = upcomingAppointments.contains { $0.status == .scheduled }
    }
}

struct Appointment: Identifiable, Codable {
    let id: UUID
    let vehicleInfo: String
    let dealerAgent: DealerAgent
    let scheduledDate: Date
    var status: AppointmentStatus
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: scheduledDate)
    }
}

enum AppointmentStatus: String, CaseIterable, Codable {
    case scheduled = "scheduled"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .scheduled:
            return "Scheduled"
        case .completed:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        }
    }
}
