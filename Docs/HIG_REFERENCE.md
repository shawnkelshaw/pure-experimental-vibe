HIG_REFERENCE.md

This document defines the design and development expectations for this app, which targets iOS 26 (public beta of iOS 18), using SwiftUI and Apple’s native iOS UI components.

📚 Reference:
🔗 https://developer.apple.com/design/human-interface-guidelines
🔗 https://developer.apple.com/documentation/swiftui/view/glassbackgroundeffect/

🎯 Project Intent

This is a native iOS application using only Apple’s official SwiftUI controls, built to comply with the latest Human Interface Guidelines and optimized for the Liquid Glass UI introduced in iOS 26.
	•	Use Apple-native layout patterns — no custom navigation or component libraries
	•	Prioritize clarity, depth, deference, and accessibility
	•	Incorporate Liquid Glass styling using .glassBackgroundEffect() where appropriate
	•	Target iPhone 16 Pro layout (393x852) as default preview resolution
	•	Respect all system standards for font scaling, semantic colors, and material rendering
	•	Use semantic text styles and accessibility modifiers (e.g., accessibilityLabel)
	•	Use the entire available set of Apple-native SwiftUI components where applicable — including but not limited to TabView, List, Form, NavigationStack, Chart, Map, Gauge, Picker, and others

🧭 Core Principles

Apple’s design language follows three key principles:
	•	Clarity – Interfaces are precise and easy to understand
	•	Deference – UI supports the content without overpowering it
	•	Depth – Transitions and visual hierarchy reinforce navigation and context

🧱 Layout & Navigation

📱 Adaptive Layout Requirements
	•	All views must adapt seamlessly to both portrait and landscape orientations
	•	Support compact and regular size classes — especially when transitioning between iPhone and iPad
	•	Use SwiftUI’s layout system (GeometryReader, .containerRelativeFrame(), adaptiveStack, etc.) to avoid fixed positioning
	•	Test across devices (e.g., iPhone 16 Pro, iPad Air, iPad Mini) in both orientations to ensure consistent spacing, alignment, and visual hierarchy
	•	Use SwiftUI-native containers: NavigationStack, TabView, Form, List
	•	Apply system spacing and safe areas using padding(), Spacer(), and .containerRelativeFrame()
	•	Avoid absolute positioning or fixed frames
	•	Support modal and sheet-based presentation with system transitions
	•	Use adaptive layouts that work in both compact and regular environments

🎨 Visual Style (iOS 26 UI + Liquid Glass)
	•	Use .glassBackgroundEffect() for surfaces and system containers (iOS 26+ only)
	•	Always wrap iOS 26-specific features in:

if #available(iOS 26, *) {
  // iOS 26 UI logic
}



🌗 Light & Dark Mode Support
	•	All views must support automatic theme switching
	•	Use only semantic colors (.primary, .background, .label, etc.)
	•	Avoid hardcoded Color.white or Color.black
	•	Maintain contrast with subtle border color shifts (~15% opacity) depending on mode
	•	Blur and shadow effects must appear native and consistent across modes

♿ Accessibility

🧱 System Spacing Utility

Use the SystemSpacing view for consistent vertical gaps between views. This utility wraps a native Spacer(minLength: 8) to promote semantic spacing aligned with system layout rhythm.

SystemSpacing()

Avoid arbitrary spacing values like .padding(.top, 13) unless explicitly required for alignment or by Apple’s design documentation.
	•	Use Dynamic Type with Text roles like .title2, .body, .caption
	•	Implement accessibilityLabel, accessibilityValue, and accessibilityHint where appropriate
	•	Avoid fixed sizing or positioning that disrupts screen reader behavior

🚫 Avoid
	•	Third-party component libraries unless explicitly approved (e.g., Swift Charts is allowed)
	•	Custom shadows or blur that override system behavior
	•	Overuse of ZStack for layout layering
	•	Fixed positioning or hardcoded frame sizes

⸻

This document evolves with iOS 26 releases. Refer to Apple’s latest Human Interface Guidelines for new updates.