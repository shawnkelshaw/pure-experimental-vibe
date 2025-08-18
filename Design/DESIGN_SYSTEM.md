# DESIGN_SYSTEM.md

## 🎨 Figma Source

Using **Apple’s official iOS 17+ Figma UI Kit**, extended for iOS 26 styling.  
Design assets include:
- Navigation Bars
- Tab Bars
- Cards
- Sheets
- Forms

Figma is used for layout thinking, not pixel-for-pixel replication.

## 🛠️ Design Workflow

- Screens are composed in Figma using Apple-native components (unaltered)
- Designs are exported to code via **Builder.io’s MCP plugin** (if applicable)
- Code implementation happens in **Cursor** using SwiftUI
- **Xcode** is used to preview on **iOS 26 simulators**, validate layout, materials, and accessibility

## 🧊 Liquid Glass Design System (iOS 26+)

| Element       | Description |
|---------------|-------------|
| **Materials** | Use `.glassBackgroundEffect()` or `.ultraThinMaterial` (no `.regularMaterial`) |
| **Transparency** | Allow content to show through layered surfaces using system glass styles |
| **Blur** | Always use contextual blur — avoid masking or stacking effects that cancel it |
| **Borders** | 1px border using semantic color with 15% opacity for contrast |
| **Themes** | Supports full light and dark mode behavior with dynamic materials and system color roles |

## 🌗 Theme Support

- App fully supports **light and dark mode**
- All backgrounds, borders, and overlays must adapt automatically
- Use only **semantic colors** — never hardcoded `.white`, `.black`, or hex values

## ✅ Component Patterns

| Component        | Design Notes |
|------------------|---------------|
| **Tab Bar**      | Uses `.glassBackgroundEffect()` and native `TabView` |
| **Cards**        | Use native containers with translucent surfaces and semantic layering |
| **Navigation Bars** | Leverage native iOS 26 glass styling — avoid custom navigation headers |
| **Typography**   | Use `Text` with `.title2`, `.body`, `.caption` — Dynamic Type must be enabled |
| **Colors**       | Use only system roles: `.primary`, `.secondary`, `.background`, `.label`, etc. |

## ⚙️ Layout and Responsiveness

- Use system spacing and safe areas
- Avoid over-layered `ZStacks`
- Use `.containerRelativeFrame()` for flexible layout
- Respect all system margins and accessibility insets
- Use Apple-native SwiftUI controls across the **entire available library** as appropriate for the feature or interaction
- Do not limit UI to a predefined subset — all Apple-provided native components (e.g., `Chart`, `Map`, `Picker`, `TextField`, `Toggle`, `Gauge`, `TimelineView`, etc.) are available for use

### 🧱 System Spacing Utility

Use the `SystemSpacing` view for consistent vertical gaps between views. This utility wraps a native `Spacer(minLength: 8)` to promote semantic spacing aligned with system layout rhythm.

```swift
SystemSpacing()