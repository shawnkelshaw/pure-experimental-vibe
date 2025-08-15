# Design Notes – iOS 26 Native App

## 🎨 Figma Source

Using **Apple’s official iOS 17+ Figma UI Kit**, extended for iOS 26 styling.  
Design assets include:
- Navigation Bars
- Tab Bars
- Cards
- Sheets
- Forms

Figma is used for layout thinking, not pixel-for-pixel replication.

---

## 🛠️ Design Workflow

- Screens are composed in Figma using Apple-native components (unaltered)
- Designs are exported to code via **Builder.io’s MCP plugin** (if applicable)
- Code implementation happens in **Cursor** using SwiftUI
- **Xcode** is used to preview on **iOS 26 simulators**, validate layout, materials, and accessibility

---

## 🧊 Liquid Glass Design System (iOS 26+)

| Element       | Description |
|---------------|-------------|
| **Materials** | Use `.glassBackgroundEffect()` or `.ultraThinMaterial` (do not use `.regularMaterial`) |
| **Transparency** | Allow content to show through layered surfaces using system glass styles |
| **Blur** | Always use contextual blur — avoid masking or stacking effects that cancel it |
| **Borders** | 1px border using semantic color with 15% opacity for contrast |
| **Themes** | Supports full light and dark mode behavior with dynamic materials and system color roles |

### 🌗 Theme Support

- App fully supports **light and dark mode**
- All backgrounds, borders, and overlays must adapt automatically to the active color scheme
- Use only **semantic colors** — never hardcoded `.white`, `.black`, or hex values
- Use `.environment(\.colorScheme)` for conditional logic only when necessary (avoid overuse)

🛑 Avoid:
- `.background(Color.white)` or `.background(Color.black)`
- Overuse of `ZStack` for layout layering
- Custom blur effects or shadows that override system materials

✅ Prefer:
- `.glassBackgroundEffect()` (wrapped in `#available(iOS 26, *)`)
- Native SwiftUI layout, spacing, and padding

---

## 🧩 Global Components

| Component        | Design Notes |
|------------------|---------------|
| **Tab Bar**      | Uses `.glassBackgroundEffect()` and native `TabView` |
| **Cards**        | Use native containers with translucent surfaces and semantic layering |
| **Navigation Bars** | Leverage native iOS 26 glass styling — avoid custom navigation headers |
| **Spacing & Layout** | Use system padding, `Spacer()`, `containerRelativeFrame()` |
| **Typography**   | Use `Text` with `.title2`, `.body`, `.caption` — Dynamic Type must be enabled |
| **Colors**       | Use only system roles: `.primary`, `.secondary`, `.background`, `.label`, etc. |

---

## ⚙️ Design System Guidelines

- 🟢 Use native SwiftUI views: `Form`, `List`, `Section`, `ScrollView`, etc.
- 🟢 Respect all system margins, paddings, and accessibility expectations
- 🔁 Use semantic font roles and appropriate accessibility modifiers
- 🔒 Avoid custom components if Apple provides a native semantic equivalent
- 🌗 All views must fully support automatic light/dark mode switching
- 🔀 Support dynamic layout changes (e.g., landscape mode, split view)

---

## 🧪 Preview Device and Expectations

- Target device: **iPhone 16 Pro (393x852)**
- Preview in **Xcode 17+ using iOS 26 simulator**
- Validate `.glassBackgroundEffect()` renders properly across modes
- Test in **both light and dark mode** to ensure consistent contrast and layering

---

> 🔁 _This design file evolves with iOS 26 and will be updated as Apple releases new materials, layout patterns, or SwiftUI APIs._