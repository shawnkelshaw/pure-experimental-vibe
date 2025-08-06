# Project Overview – PlayingAround

# Project Overview – PlayingAround

**App Goal:**  
PlayingAround is a native iOS app built with Swift and SwiftUI, following Apple's **iOS 26 Human Interface Guidelines** (iOS 18 public release). The app helps users manage **Vehicle Passports** — digital profiles of a vehicle's static and dynamic attributes, including VIN, mileage, number of owners, and purchase date.

Vehicle Passports can be broadcast to the physical world around a vehicle using Bluetooth or near-field transmissions. This enables peer-to-peer networking for direct sales opportunities between mobile devices.

Additionally, Vehicle Passports can be transferred from dealership sales agents to new owners after a sales transaction is complete. Just like a VIN, a Vehicle Passport is unique and can belong to only one vehicle at a time. It travels with the vehicle as ownership changes. Once the vehicle reaches its end of life, the passport is retired.

---

## 🔧 Technical Configuration

- **Target SDK**: iOS 26 (Xcode 17 Beta 4+)
- **Deployment Target**: iOS 18.5
- **Device Preview Target**: iPhone 16 Pro (393x852pt)
- **Swift Version**: 5.10
- **Architecture**: MVVM
- **Frameworks**: SwiftUI, Combine (if needed)
- **3rd-Party**: No external libraries unless explicitly approved

---

## 🧪 UI / Design System

- **Design System**: Apple iOS 17 UI Kit (until official iOS 18 kit is available)
- **Design Principles**:
  - Use native SwiftUI components (`TabView`, `List`, `Form`, `NavigationStack`)
  - Avoid hardcoded colors or custom materials
  - Use semantic system colors (`.primary`, `.secondary`, etc.)
  - Support automatic light/dark mode switching

- **Liquid Glass UI Guidelines**:
  - Use `.glassBackground()` (iOS 26+ only)
  - Wrap liquid glass usage in `if #available(iOS 26, *)` blocks
  - Avoid overriding background with `.background(Color.white)`
  - Use `.glassBackground()` for tab bars, cards, sheets, modals
  - Preserve transparency to allow layered blur rendering