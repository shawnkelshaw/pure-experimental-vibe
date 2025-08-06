# Design Notes

**Figma Source:**  
Using Apple's official iOS 17 Figma UI Kit. Design assets include Navigation Bars, Cards, Sheets, and Forms.

**Design Workflow:**  
- Screens are composed in Figma using official Apple components (unchanged).
- Exported via Builder.io's MCP plugin where applicable.
- Cursor converts design to SwiftUI Views.
- Xcode previews and validates UI behavior and rendering.

**Liquid Glass Design System:**  
- **Materials**: Implementing Apple's liquid glass design with `.regularMaterial`, `.thinMaterial`, and `.ultraThinMaterial`
- **Transparency**: Layered translucent surfaces that reveal content behind
- **Blur Effects**: Contextual frosted glass appearance for depth and hierarchy
- **Adaptive Glass Borders**: Dark borders on light mode, light borders on dark mode (15% opacity)
- **Theme Support**: Full light and dark mode support with adaptive colors

**Global Components:**  
- **Tab Bar** with liquid glass translucent background and blur effects
- **Cards**: Built using native SwiftUI materials with liquid glass effects
- **Spacing & Layout**: Follows Apple system defaults and safe areas  
- **Typography & Colors**: Native fonts and semantic color styles from SwiftUI

**Design System Notes:**  
- Prefer system views (`Form`, `List`, `Section`, etc.) when possible  
- Avoid custom UI if Apple provides a semantically correct component  
- Reference iOS 17 HIG when designing new flows or screens
- Implement liquid glass materials for modern, translucent aesthetics
- Support automatic light/dark mode switching with adaptive color system
- Use semantic colors (.primary, .secondary) instead of hardcoded colors