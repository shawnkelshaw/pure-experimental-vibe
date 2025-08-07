import SwiftUI

struct BluetoothNotificationView: View {
    let notification: PendingNotification
    let onConfirm: () async -> Void
    let onDismiss: () async -> Void
    
    @State private var isAnimating = false
    @State private var isProcessing = false
    
    var body: some View {
        ZStack {
            // Semi-transparent dark background
            Color.black.opacity(0.7)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    // Prevent dismissal on background tap for important notifications
                }
            
            VStack {
                Spacer()
                
                // Notification Card
                VStack(spacing: 24) {
                    // Bluetooth Animation Icon
                    VStack(spacing: 16) {
                        ZStack {
                            // Animated outer rings
                            ForEach(0..<3, id: \.self) { index in
                                Circle()
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                                    .frame(width: 80 + CGFloat(index * 20), height: 80 + CGFloat(index * 20))
                                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                                    .opacity(isAnimating ? 0.0 : 0.7)
                                    .animation(
                                        .easeInOut(duration: 2.0)
                                        .repeatForever(autoreverses: false)
                                        .delay(Double(index) * 0.3),
                                        value: isAnimating
                                    )
                            }
                            
                            // Central Bluetooth Icon
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                                
                                Image(systemName: notification.type.iconName)
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(height: 120)
                    }
                    
                    // Notification Content
                    VStack(spacing: 12) {
                        Text(notification.title)
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(notification.message)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .padding(.horizontal, 8)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        // Accept Button
                        Button(action: {
                            guard !isProcessing else { return }
                            isProcessing = true
                            
                            Task {
                                await onConfirm()
                                isProcessing = false
                            }
                        }) {
                            HStack {
                                if isProcessing {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                
                                Text(isProcessing ? "Accepting..." : "Accept")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(.white)
                            )
                        }
                        .disabled(isProcessing)
                        .buttonStyle(PlainButtonStyle())
                        .scaleEffect(isProcessing ? 0.95 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isProcessing)
                        
                        // Dismiss Button
                        Button(action: {
                            guard !isProcessing else { return }
                            
                            Task {
                                await onDismiss()
                            }
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text("Dismiss")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(isProcessing)
                        .buttonStyle(PlainButtonStyle())
                        .opacity(isProcessing ? 0.5 : 1.0)
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.black.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.blue.opacity(0.1), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 20)
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .opacity(isAnimating ? 1.0 : 0.0)
                
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Generic Notification View
struct NotificationOverlayView: View {
    let notification: PendingNotification
    let onConfirm: () async -> Void
    let onDismiss: () async -> Void
    
    var body: some View {
        Group {
            switch notification.type {
            case .bluetoothPassportPush:
                BluetoothNotificationView(
                    notification: notification,
                    onConfirm: onConfirm,
                    onDismiss: onDismiss
                )
            case .maintenanceReminder, .documentExpiry, .other:
                GenericNotificationView(
                    notification: notification,
                    onConfirm: onConfirm,
                    onDismiss: onDismiss
                )
            }
        }
    }
}

// MARK: - Generic Notification for Other Types
struct GenericNotificationView: View {
    let notification: PendingNotification
    let onConfirm: () async -> Void
    let onDismiss: () async -> Void
    
    @State private var isAnimating = false
    @State private var isProcessing = false
    
    var body: some View {
        ZStack {
            // Semi-transparent dark background
            Color.black.opacity(0.7)
                .ignoresSafeArea(.all)
            
            VStack {
                Spacer()
                
                // Notification Card
                VStack(spacing: 20) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.orange, lineWidth: 2)
                            )
                        
                        Image(systemName: notification.type.iconName)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.orange)
                    }
                    
                    // Content
                    VStack(spacing: 12) {
                        Text(notification.title)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(notification.message)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            Task {
                                await onDismiss()
                            }
                        }) {
                            Text("Dismiss")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            Task {
                                await onConfirm()
                            }
                        }) {
                            Text("OK")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.black)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.white)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .opacity(isAnimating ? 1.0 : 0.0)
                
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Preview
struct BluetoothNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleNotification = PendingNotification.bluetoothPassportPush(
            userId: UUID(),
            vehicleName: "2023 Tesla Model 3"
        )
        
        BluetoothNotificationView(
            notification: sampleNotification,
            onConfirm: {},
            onDismiss: {}
        )
        .previewDevice("iPhone 15 Pro")
        .previewDisplayName("Bluetooth Notification")
    }
} 