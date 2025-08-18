
⸻

PROJECT_OVERVIEW.md

App Goal:
PlayingAround is a native iOS app built with Swift and SwiftUI, following Apple’s iOS 26 Human Interface Guidelines (iOS 18 public release). The app helps users manage Vehicle Passports — digital profiles of a vehicle’s static and dynamic attributes, including VIN, mileage, number of owners, and purchase date.

Vehicle Passports can be broadcast to the physical world around a vehicle using Bluetooth or near-field transmissions. This enables peer-to-peer networking for direct sales opportunities between mobile devices.

Additionally, Vehicle Passports can be transferred from dealership sales agents to new owners after a sales transaction is complete. Just like a VIN, a Vehicle Passport is unique and can belong to only one vehicle at a time. It travels with the vehicle as ownership changes. Once the vehicle reaches its end of life, the passport is retired.

⸻

🔧 Technical Configuration
	•	Target SDK: iOS 26 (Xcode 17 Beta 4+)
	•	Deployment Target: iOS 18.5
	•	Device Preview Target: iPhone 16 Pro (393x852pt)
	•	Swift Version: 5.10
	•	Architecture: MVVM
	•	Frameworks: SwiftUI, Combine (if needed)
	•	3rd-Party: Prefer Apple-native frameworks; third-party libraries (e.g., Swift Charts) may be used if:
	•	They are maintained, well-documented, and follow Apple’s HIG
	•	Their usage does not conflict with the Liquid Glass design system or native behavior
	•	Their purpose is to extend native capabilities, not replace them

⸻

🧪 UI / Design System
	•	Design System: Apple iOS 17 UI Kit (until official iOS 18 kit is available)
	•	Design Principles:
	•	Use Apple-native SwiftUI controls across the full range of available components
	•	Prefer standard Apple components such as TabView, List, Form, NavigationStack, Chart, Map, Picker, TextField, Toggle, etc.
	•	Avoid reinventing components that are already provided by SwiftUI
	•	Avoid hardcoded colors or custom materials
	•	Use semantic system colors (.primary, .secondary, etc.)
	•	Support automatic light/dark mode switching
	•	Support accessibility with Dynamic Type, appropriate accessibility modifiers, and screen reader hints
	•	Liquid Glass UI Guidelines:
	•	Use .glassBackgroundEffect() (iOS 26+ only)
	•	Wrap usage in if #available(iOS 26, *) blocks
	•	Avoid overriding background with .background(Color.white)
	•	Use .glassBackgroundEffect() for tab bars, cards, sheets, modals
	•	Preserve transparency to allow layered blur rendering

⸻

📡 Data Layer & API

The app integrates with Supabase as a backend for:
	•	Vehicle data warehousing
	•	User authentication
	•	Metadata for ownership, listings, and sessions

Some layers of the experience are simulated for prototyping:
	•	Bluetooth notifications: Simulated in app logic (for now)
	•	QR scanning: Mock input, with static scan response
	•	Offline placeholders: Used where data hasn’t been synced or for non-critical UI states

📎 See api.md for more technical details.

⸻
