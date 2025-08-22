# Voiceflow Integration Plan
## Vehicle Passport - Dealer Trade-In Appointment Scheduling

### Overview
This document outlines the integration strategy for Voiceflow to handle voice-based appointment scheduling with dealer agents for vehicle trade-ins.

### Current Implementation Status
✅ **Completed Core Flow:**
- Mock dealer agent data (Alan Subran, Savannah Tesla)
- 4-6 second retrieval simulation
- Confirmation alert with vehicle-specific details
- YES/NO decision handling
- Vehicle context preparation
- Appointment service with red badge notifications
- "Upcoming Events and Appointments" in More tab

### Integration Options

#### Option 1: WebView Integration (Recommended)
**Pros:**
- Fastest implementation
- No SDK dependencies
- Full Voiceflow UI experience
- Easy to update/modify flows

**Cons:**
- Less native feel
- Requires internet connection
- Limited iOS integration

**Implementation:**
```swift
struct VoiceflowWebView: UIViewRepresentable {
    let voiceflowURL: String
    let vehicleContext: [String: Any]
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        // Configure with vehicle context
        return webView
    }
}
```

#### Option 2: Voiceflow API Integration
**Pros:**
- More native integration
- Better error handling
- Custom UI possible

**Cons:**
- More complex implementation
- API rate limits
- Requires API key management

#### Option 3: Voiceflow SDK (If Available)
**Pros:**
- Native iOS experience
- Offline capabilities
- Deep integration

**Cons:**
- SDK availability uncertain
- Larger app size
- More complex setup

### Recommended Implementation Plan

#### Phase 1: WebView Integration
1. **Create VoiceflowService**
   - Manage Voiceflow project URL
   - Handle context passing
   - Manage session state

2. **Update MarketView Integration**
   - Replace TODO in `handleScheduleAppointment()`
   - Present VoiceflowWebView modally
   - Pass vehicle context via URL parameters

3. **Context Passing Strategy**
   ```swift
   let contextParams = [
       "vehicle_year": vehicle.year,
       "vehicle_make": vehicle.make,
       "vehicle_model": vehicle.model,
       "dealer_agent": agent.name,
       "dealer_name": agent.dealership,
       "user_zip": currentZipCode
   ]
   ```

#### Phase 2: Enhanced Integration
1. **Bidirectional Communication**
   - JavaScript bridge for appointment confirmation
   - Return appointment details to iOS
   - Update AppointmentService with real data

2. **Error Handling**
   - Network connectivity checks
   - Fallback to phone/email contact
   - Retry mechanisms

#### Phase 3: Advanced Features
1. **Calendar Integration**
   - EventKit framework
   - Add appointments to user's calendar
   - Reminder notifications

2. **Voice Permissions**
   - Microphone access handling
   - Privacy policy updates
   - User consent flows

### Voiceflow Project Setup Requirements

#### Project Configuration
- **Project Type:** Voice Assistant
- **Platform:** Web (for WebView integration)
- **Language:** English
- **Integration:** Custom webhook for calendar

#### Required Intents/Flows
1. **Appointment Scheduling**
   - Date/time selection
   - Confirmation of vehicle details
   - Dealer agent verification

2. **Calendar Integration**
   - Google Calendar API setup
   - Appointment creation
   - Confirmation email/SMS

3. **Error Handling**
   - Invalid dates
   - Dealer unavailability
   - System errors

#### Context Variables Needed
```json
{
  "vehicle_year": "2023",
  "vehicle_make": "Tesla",
  "vehicle_model": "Model 3",
  "vehicle_vin": "5YJ3E1EA1KF123456",
  "dealer_agent_name": "Alan Subran",
  "dealer_name": "Savannah Tesla",
  "dealer_phone": "(912) 555-0123",
  "user_zip_code": "31405"
}
```

### Implementation Timeline
- **Week 1:** Voiceflow project setup and basic flow creation
- **Week 2:** WebView integration and context passing
- **Week 3:** Bidirectional communication and appointment confirmation
- **Week 4:** Testing, error handling, and polish

### Next Steps
1. Create Voiceflow account and project
2. Design conversation flow for appointment scheduling
3. Set up Google Calendar integration
4. Implement WebView integration in iOS app
5. Test end-to-end flow

### Technical Considerations
- **Privacy:** Microphone permissions, data handling
- **Performance:** WebView loading times, memory usage
- **Accessibility:** Voice commands, screen reader support
- **Internationalization:** Multi-language support if needed

### Fallback Strategy
If Voiceflow integration faces issues:
1. **Native iOS Form:** Simple date/time picker
2. **Phone Call Integration:** Direct dial to dealer
3. **Email Integration:** Pre-filled appointment request email
