# Human Interface Guidelines – iOS 26 (SwiftUI, Liquid Glass)

This document defines the design and development expectations for this app, which targets **iOS 26** (public beta of iOS 18), using **SwiftUI** and **Apple's native iOS UI components**.

📚 Reference:  
🔗 https://developer.apple.com/design/human-interface-guidelines  
🔗 https://developer.apple.com/documentation/swiftui/view/glassbackground/

---

## 🎯 Project Intent

This is a **native iOS application** using only **Apple’s official SwiftUI controls**, built to comply with the latest **Human Interface Guidelines** and optimized for the **Liquid Glass UI introduced in iOS 26**.

- Use **Apple-native layout patterns** — no custom navigation or component libraries
- Prioritize **clarity, depth, deference**, and **accessibility**
- Incorporate **Liquid Glass styling** using `.glassBackgroundEffect()` where appropriate
- Target **iPhone 16 Pro layout** (393x852) as default preview resolution
- Respect all system standards for **font scaling**, **semantic colors**, and **material rendering**

---

## 🧭 Core Principles

Apple’s design language follows three key principles:

- **Clarity** – Interfaces are precise and easy to understand
- **Deference** – UI supports the content without overpowering it
- **Depth** – Transitions and visual hierarchy reinforce navigation and context

---

## 🧱 Layout & Navigation

- Use SwiftUI-native containers: `NavigationStack`, `TabView`, `Form`, `List`
- Apply system spacing and safe areas using `padding()`, `Spacer()`, and `.containerRelativeFrame()`
- Avoid absolute positioning or fixed frames
- Support modal and sheet-based presentation with system transitions
- Use adaptive layouts that work in both compact and regular environments

---

## 🎨 Visual Style (iOS 26 UI + Liquid Glass)

- Use `.glassBackgroundEffect()` for surfaces and system containers (iOS 26+ only)
- Always wrap iOS 26-specific features in:
  ```swift
  if #available(iOS 26, *) {
    // iOS 26 UI logic
  }

  ---

  ### 🌗 Light & Dark Mode Support

- All views must support **automatic theme switching**
- Use only **semantic colors** (`.primary`, `.background`, `.label`, etc.)
- Avoid hardcoded `Color.white` or `Color.black` — they do not adapt
- Glass surfaces must maintain visual contrast:
  - Light Mode → use subtle dark borders
  - Dark Mode → use subtle light borders (15% opacity recommended)
- All effects, shadows, and glass layers must appear natural in both modes