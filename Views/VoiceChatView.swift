import SwiftUI
import UIKit

struct VoiceChatView: View {
    @StateObject private var voiceService = VoiceAgentService()
    @State private var showSuccessToast = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appointmentService: AppointmentService
    
    let vehicle: Vehicle
    let passport: VehiclePassport
    let dealerAgent: DealerAgent
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: .loose) {
                    // Header with vehicle info
                    VStack(spacing: .tight) {
                        Text("Trade-in Appointment")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("\(String(vehicle.year)) \(vehicle.make) - \(vehicle.model)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Agent: \(dealerAgent.name)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, .medium)
                    
                    // Voice visualization
                    VoiceWaveformView(
                        isActive: voiceService.isListening || voiceService.isSpeaking,
                        audioLevel: voiceService.audioLevel,
                        isListening: voiceService.isListening
                    )
                    .frame(height: 120)
                    
                    // Status indicator (positioned under voice animation)
                    StatusIndicatorView(state: voiceService.conversationState)
                    
                    // Start Voice Chat button (moved closer to animation)
                    if voiceService.conversationState == .idle {
                        Button(action: {
                            voiceService.startConversation()
                        }) {
                            Text("Start voice chat")
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .buttonBorderShape(.roundedRectangle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Current message display
                    if !voiceService.currentMessage.isEmpty {
                        ScrollView {
                            Text(voiceService.currentMessage)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxHeight: 120)
                    }
                    
                    // Response buttons (Yes/No after first message) — stacked vertically, full-width within padding
                    if voiceService.showResponseButtons {
                        VStack(spacing: .tight) {
                            Button(action: {
                                voiceService.handleUserResponse("Yes")
                            }) {
                                Text("Yes")
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .buttonBorderShape(.roundedRectangle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                voiceService.handleUserResponse("No")
                            }) {
                                Text("No, get new time")
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                            .buttonBorderShape(.roundedRectangle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Confirm appointment button with loading state
                    if voiceService.conversationState == .waitingForAction {
                        Button(action: {
                            // Haptic feedback on confirm
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            
                            // Show success toast immediately
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                showSuccessToast = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    showSuccessToast = false
                                }
                            }
                            
                            voiceService.confirmAction()
                        }) {
                            if voiceService.isConfirming {
                                HStack(spacing: .tight) {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                    Text("Confirming…")
                                }
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                            } else {
                                Text("Confirm appointment")
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .buttonBorderShape(.roundedRectangle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .disabled(voiceService.isConfirming)
                        .onChange(of: voiceService.isConfirming) { newValue in
                            if newValue {
                                // Schedule the appointment immediately when confirming starts
                                let vehicleInfo = "\(vehicle.year) \(vehicle.make) \(vehicle.model)"
                                appointmentService.scheduleAppointment(
                                    vehicleInfo: vehicleInfo,
                                    dealerAgent: dealerAgent
                                )
                                
                                // Stop any ongoing speech and dismiss after 3 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                    voiceService.endConversation()
                                    dismiss()
                                }
                            }
                        }
                    }
                    
                    // End Chat button moved to safe area inset at bottom
                    
                    // Done button (moved up)
                    if voiceService.conversationState == .completed {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Done")
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .buttonBorderShape(.roundedRectangle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, .medium)
                    }
                    
                    Spacer()
                }
                .systemHorizontalPadding()
            }
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(voiceService.conversationState != .idle && voiceService.conversationState != .completed)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if voiceService.conversationState == .idle || voiceService.conversationState == .completed {
                        Button("Close") {
                            voiceService.endConversation()
                            dismiss()
                        }
                    }
                }
            }
            .overlay(alignment: .top) {
                if showSuccessToast {
                    ToastView(message: "Appointment confirmed")
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if voiceService.conversationState != .completed && voiceService.conversationState != .idle {
                    Button(action: {
                        voiceService.endConversation()
                        dismiss()
                    }) {
                        Text("End chat")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .buttonStyle(.bordered)
                    .tint(Color(.systemRed))
                    .buttonBorderShape(.roundedRectangle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .systemHorizontalPadding()
                    .padding(.bottom, .medium)
                }
            }
        }
        .onDisappear {
            voiceService.endConversation()
        }
    }
}

private struct ToastView: View {
    let message: String
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
            Text(message)
                .foregroundColor(.white)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule().fill(Color(.systemGreen))
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
    }
}

struct VoiceWaveformView: View {
    let isActive: Bool
    let audioLevel: Float
    let isListening: Bool
    
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: .extraTight) {
            ForEach(0..<20, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(barColor)
                    .frame(width: 6, height: barHeight(for: index))
                    .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: isActive)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isListening ? Color(.systemRed) : Color(.systemBlue), lineWidth: isActive ? 2 : 0)
                )
        )
    }
    
    private var barColor: Color {
        if isListening {
            return Color(.systemRed)
        } else if isActive {
            return Color(.systemBlue)
        } else {
            return Color(.systemGray).opacity(0.3)
        }
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        let baseHeight: CGFloat = 8
        let maxHeight: CGFloat = 60
        
        if isActive {
            let variation = CGFloat(audioLevel) * (maxHeight - baseHeight)
            let indexMultiplier = sin(Double(index) * 0.5 + Double(animationOffset))
            return baseHeight + variation * CGFloat(abs(indexMultiplier))
        } else {
            return baseHeight
        }
    }
}

struct StatusIndicatorView: View {
    let state: VoiceAgentService.ConversationState
    
    var body: some View {
        HStack(spacing: .tight) {
            Circle()
                .fill(statusColor)
                .frame(width: .mediumTight, height: .mediumTight)
            
            Text(statusText)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(statusColor)
        }
    }
    
    private var statusColor: Color {
        switch state {
        case .idle:
            return Color(.systemGray)
        case .requestingPermission:
            return Color(.systemOrange)
        case .listening:
            return Color(.systemRed)
        case .processing:
            return Color(.systemYellow)
        case .speaking:
            return Color(.systemBlue)
        case .waitingForUserResponse:
            return Color(.systemBlue)
        case .waitingForAction:
            return Color(.systemGreen)
        case .completed:
            return Color(.systemGreen)
        }
    }
    
    private var statusText: String {
        switch state {
        case .idle:
            return "Ready to start"
        case .requestingPermission:
            return "Requesting permissions..."
        case .listening:
            return "Listening..."
        case .processing:
            return "Processing..."
        case .speaking:
            return "Agent speaking..."
        case .waitingForUserResponse:
            return "Waiting for your response..."
        case .waitingForAction:
            return "Tap to confirm"
        case .completed:
            return "Appointment scheduled!"
        }
    }
    
    private var isAnimated: Bool {
        switch state {
        case .listening, .processing, .speaking, .waitingForUserResponse:
            return true
        default:
            return false
        }
    }
}

struct VoiceChatView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceChatView(
            vehicle: Vehicle(
                id: UUID(),
                userId: UUID(),
                make: "Tesla",
                model: "Model 3",
                year: 2023,
                vin: "1HGBH41JXMN109186",
                licensePlate: nil,
                mileage: 15000,
                fuelType: .electric,
                transmission: .automatic,
                color: "Pearl White"
            ),
            passport: VehiclePassport(vehicleId: UUID()),
            dealerAgent: DealerAgent(
                id: UUID(),
                name: "Alan Subran",
                dealership: "Savannah Tesla",
                phone: "(912) 555-0123",
                email: "alan@savannahtesla.com",
                specialties: ["Tesla Trade-ins", "EV Specialist"],
                rating: 4.8
            )
        )
    }
}
