import Foundation
import AVFoundation
import Speech

@MainActor
class VoiceAgentService: ObservableObject {
    @Published var isListening = false
    @Published var isSpeaking = false
    @Published var conversationState: ConversationState = .idle
    @Published var currentMessage = ""
    @Published var audioLevel: Float = 0.0
    @Published var showResponseButtons = false
    @Published var isConfirming = false
    
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    enum ConversationState {
        case idle
        case requestingPermission
        case listening
        case processing
        case speaking
        case waitingForUserResponse
        case waitingForAction
        case completed
    }
    
    // Mock conversation flow for appointment scheduling
    private var conversationStep = 0
    private let mockResponses = [
        "Hi. I'm Alan's digital twin. I have access to Alan's calendar and can see he has availability anytime on Tuesday after 1:00 pm. Would 2:00 pm be good for you?",
        "Great choice! What time of day works best for you - morning, afternoon, or evening?",
        "Perfect! I can schedule you for Tuesday afternoon. Would you like me to confirm this appointment?",
        "Excellent! I've scheduled your appointment for Tuesday afternoon with Alan Subran at Savannah Tesla. You'll receive a confirmation shortly."
    ]
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func startConversation() {
        conversationState = .requestingPermission
        requestPermissions()
    }
    
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self?.requestMicrophonePermission()
                case .denied, .restricted, .notDetermined:
                    self?.conversationState = .idle
                    print("Speech recognition not authorized")
                @unknown default:
                    self?.conversationState = .idle
                }
            }
        }
    }
    
    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.startInitialGreeting()
                } else {
                    self?.conversationState = .idle
                    print("Microphone permission denied")
                }
            }
        }
    }
    
    private func startInitialGreeting() {
        conversationState = .speaking
        speakMessage(mockResponses[0])
    }
    
    private func speakMessage(_ message: String) {
        currentMessage = message
        isSpeaking = true
        
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        
        speechSynthesizer.speak(utterance)
        
        // Simulate speaking animation
        startSpeakingAnimation()
        
        // Calculate speech duration and extend animation by 2 seconds
        let speechDuration = Double(message.count) * 0.1
        let animationDuration = speechDuration + 2.0
        
        // Wait for speech to complete, then show response buttons for first message
        DispatchQueue.main.asyncAfter(deadline: .now() + speechDuration) {
            self.isSpeaking = false
        }
        
        // Keep animation running for 2 seconds longer
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            if self.conversationStep == 0 {
                self.conversationState = .waitingForUserResponse
                self.showResponseButtons = true
            } else {
                self.startListening()
            }
        }
    }
    
    private func startSpeakingAnimation() {
        // Simulate audio levels while speaking
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.isSpeaking {
                self.audioLevel = Float.random(in: 0.3...0.8)
            } else {
                timer.invalidate()
                self.audioLevel = 0.0
            }
        }
    }
    
    private func startListening() {
        conversationState = .listening
        isListening = true
        
        // Simulate listening for 3 seconds, then process response
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.processUserResponse()
        }
        
        // Simulate microphone input levels
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.isListening {
                self.audioLevel = Float.random(in: 0.1...0.6)
            } else {
                timer.invalidate()
                self.audioLevel = 0.0
            }
        }
    }
    
    private func processUserResponse() {
        isListening = false
        conversationState = .processing
        
        // Simulate processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.conversationStep += 1
            
            if self.conversationStep < self.mockResponses.count {
                if self.conversationStep == self.mockResponses.count - 2 {
                    // Show action button before final response
                    self.conversationState = .waitingForAction
                } else {
                    self.speakMessage(self.mockResponses[self.conversationStep])
                }
            } else {
                self.conversationState = .completed
            }
        }
    }
    
    func confirmAction() {
        // Mark confirming state; the view will handle dismissal timing
        isConfirming = true
    }
    
    func handleUserResponse(_ response: String) {
        showResponseButtons = false
        conversationStep += 1
        
        if response == "Yes" {
            // Speak confirmation prompt and wait for user action
            let prompt = "Excellent. The appointment is being set for Tuesday at 2:00 p.m. at Savannah Tesla with Alan Subran. Please click the confirm button below."
            speakMessage(prompt)
            conversationState = .waitingForAction
        } else {
            // Continue with next response
            if conversationStep < mockResponses.count {
                speakMessage(mockResponses[conversationStep])
            }
        }
    }
    
    func endConversation() {
        isListening = false
        isSpeaking = false
        conversationState = .idle
        conversationStep = 0
        audioLevel = 0.0
        showResponseButtons = false
        isConfirming = false
        speechSynthesizer.stopSpeaking(at: .immediate)
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }
    }
}
