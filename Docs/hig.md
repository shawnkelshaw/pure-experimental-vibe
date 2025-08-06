# Apple Human Interface Guidelines (HIG) Reference – iOS 26

This document reflects Apple’s latest guidance for native iOS app design using SwiftUI, including **Liquid Glass UI** features introduced in iOS 26 (iOS 18 public beta).

📚 Reference:  
🔗 https://developer.apple.com/design/human-interface-guidelines  
🔗 https://developer.apple.com/documentation/swiftui/view/glassbackground()

---

## 🧭 Core Principles

Apple’s design system emphasizes:

- **Clarity** – Interfaces are legible, precise, and easy to understand.
- **Deference** – UI supports the content without competing with it.
- **Depth** – Realistic transitions, layering, and motion convey hierarchy.

---

## 🧱 Layout & Navigation

- Use **safe areas**, **adaptive layout containers**, and **system spacing**
- Leverage native containers: `NavigationStack`, `TabView`, `Form`, `List`
- Present content via **sheets**, **modals**, or **detail views** using new iOS 26 transitions
- Avoid fixed positions — support **dynamic layout** and **compact/regular environments**

---

## 🎨 Visual Style (Updated for iOS 26)

- Use system-provided **blur materials**: `.glassBackground()` (iOS 26+ only)
- Avoid `ZStack` overlays that suppress transparency or blur
- Use **semantic colors**: `.primary`, `.secondary`, `.background`, `.label`
- Full support for **light/dark mode** and **adaptive contrast**
- Use `.background()` sparingly to preserve depth and compositing

### 🧊 Liquid Glass Best Practices

| Rule | Description |
|------|-------------|
| ✅ Use `.glassBackground()` | For tab bars, cards, modals, and surfaces |
| 🔒 Wrap in `if #available(iOS 26, *)` | Prevent crashes on older iOS versions |
| 🚫 Avoid `.background(Color.white)` | Kills the blur and visual depth |
| ✅ Use layered transparency | Ensures depth and hierarchy render correctly |
| 🎨 Border hinting | Use 15% opacity borders for contrast when needed |

---

## 🔤 Typography

- Use system fonts and roles: `.largeTitle`, `.title2`, `.body`, `.caption`
- Support **Dynamic Type** and **Accessibility sizes**
- Avoid fixed font sizes and custom font scaling

---

## 🧑‍🦽 Accessibility

- Add `.accessibilityLabel()`, `.accessibilityHint()`, and roles for interactive elements
- Ensure minimum touch targets (44×44 pt)
- Use `.accessibilitySortPriority()` when controlling element order
- Test with VoiceOver and Dynamic Type enabled

---

## 🧱 Components

- Use system-native SwiftUI controls:
  - `Button`, `TextField`, `Toggle`, `Form`, `List`, `ScrollView`, `DatePicker`
- Adopt iOS 26 refinements:
  - `formStyle(.automatic)` or `.grouped`
  - Native `sheet` behavior with full-screen blur
- Enable swipe actions, drag-and-drop, and haptics when relevant

---

## ✅ View Checklist

For each new screen or component:
- [ ] Uses SwiftUI and Swift 5.10
- [ ] Targets iOS 26+ features via `#available` checks
- [ ] Respects layout margins and system spacing
- [ ] Uses `.glassBackground()` where appropriate
- [ ] Avoids conflicting `.background()` or `.opacity()` calls
- [ ] Uses semantic system colors and fonts
- [ ] Supports light/dark mode and Dynamic Type
- [ ] Includes accessibility labels and roles
- [ ] Previews on iPhone 16 Pro simulator
- [ ] Follows MVVM architecture with clean separation of concerns

---

> ℹ️ _Update this document as iOS 26 matures or new UI guidance is released. Refer to Apple’s [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines) regularly when introducing new views or patterns._