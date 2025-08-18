# PlayingAround – iOS Native App

**PlayingAround** is a native iOS app built with Swift and SwiftUI, designed around Apple’s **iOS 26 Human Interface Guidelines**. It enables users to create, manage, and transfer digital **Vehicle Passports** — structured records that capture a vehicle's static and dynamic history.

The app supports peer-to-peer networking for digital vehicle handoff via simulated **Bluetooth notifications** and **QR code scans**, and is backed by a live **Supabase** instance for data warehousing and authentication.

---

## 📁 Project Structure & Documentation

All project constraints, architectural assumptions, and design rules are documented and enforced through the following files:

### 🔧 Core Docs (`/Docs/`)

| File                                  | Purpose                                                                 |
| ------------------------------------- | ----------------------------------------------------------------------- |
| `PROJECT_OVERVIEW.md`                 | Defines architecture, SDKs, and app goals                               |
| `API_INTEGRATION.md`                  | Explains Supabase, mocked data, Bluetooth simulation, and QR flows      |
| `HIG_REFERENCE.md`                    | Interprets Apple’s Human Interface Guidelines (iOS 26) for this project |
| `SUPABASE_INTEGRATION_GUIDE.md`       | Developer guide to backend setup, auth, storage, and subscriptions      |
| `SEMANTIC_COLOR_MIGRATION_SUMMARY.md` | Historical record of semantic color migration and implementation impact |

### 🎨 Visual System (`/Design/`)

| File               | Purpose                                                                 |
| ------------------ | ----------------------------------------------------------------------- |
| `DESIGN_SYSTEM.md` | Documents layout, component patterns, spacing rules, and visual styling |

These documents serve as the **source of truth** for developers, designers, and AI coding assistants (Cursor, Claude, GPT, etc.).

---

## 🧠 AI/Assistant Usage Guidelines

Any AI agent or pair-programming assistant should:

* Use **Apple-native SwiftUI components only** unless otherwise specified
* Follow the rules in `Docs/HIG_REFERENCE.md` and `Design/DESIGN_SYSTEM.md`
* Support layout that adapts to **iPhone and iPad** in **portrait and landscape** orientations
* Prefer `.glassBackgroundEffect()` and other native iOS 26 materials
* Avoid using third-party libraries unless noted in `PROJECT_OVERVIEW.md`
* Avoid custom UI controls when a native SwiftUI solution exists

Reference comments may be placed at the top of view files to reinforce expectations:

```swift
// Reference: Docs/HIG_REFERENCE.md and Design/DESIGN_SYSTEM.md
// Constraints:
// - Use Apple-native SwiftUI controls
// - Follow iOS 26 Human Interface Guidelines
// - Avoid custom or third-party components unless explicitly allowed
```

---

## 🧪 Current Prototype Status

* ✅ Supabase integrated for auth and vehicle data
* ✅ QR and Bluetooth interactions simulated
* ✅ Glass material views tested on iPhone 16 Pro (393x852)
* ⚠️ Local caching pending
* ⚠️ UI state loading refinements in progress

---

> This project evolves with Apple’s platform updates. For guidance, always consult the latest versions of the markdown files in `/Docs/` and `/Design/`.
