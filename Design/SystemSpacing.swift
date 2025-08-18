//
//  SystemSpacing.swift
//  Vehicle Passport
//
//  Created by Shawn Kelshaw on August 2025.
//

// Reference: Design/DESIGN_SYSTEM.md
// Purpose:
// - Provides standardized vertical spacing
// - Aligns with Apple’s semantic layout principles
// - Use in place of ad hoc `.padding()` or hardcoded `Spacer()` gaps

import SwiftUI

// MARK: - System Spacing Extension
// Based on Apple's Human Interface Guidelines spacing values

extension CGFloat {
    /// Apple's standard system spacing values for iOS
    /// These follow the 8pt grid system used throughout iOS
    
    /// Extra tight spacing (4pt) - For very compact layouts
    static let extraTight: CGFloat = 4
    
    /// Tight spacing (8pt) - For compact elements
    static let tight: CGFloat = 8
    
    /// Standard spacing (12pt) - For medium-tight layouts
    static let mediumTight: CGFloat = 12
    
    /// Regular spacing (16pt) - Default system spacing, most common
    static let regular: CGFloat = 16
    
    /// Medium spacing (20pt) - For breathing room between sections
    static let medium: CGFloat = 20
    
    /// Loose spacing (24pt) - For distinct section separation
    static let loose: CGFloat = 24
    
    /// Extra loose spacing (32pt) - For major section breaks
    static let extraLoose: CGFloat = 32
}

extension EdgeInsets {
    /// Standard system edge insets for different contexts
    
    /// Card padding - standard internal spacing
    static let cardPadding = EdgeInsets(top: .medium, leading: .regular, bottom: .medium, trailing: .regular)
    
    /// Section padding - for major content sections
    static let sectionPadding = EdgeInsets(top: .loose, leading: .regular, bottom: .loose, trailing: .regular)
    
    /// Compact padding - for tight layouts
    static let compactPadding = EdgeInsets(top: .tight, leading: .mediumTight, bottom: .tight, trailing: .mediumTight)
}

// MARK: - Convenient View Modifiers
extension View {
    /// Apply standard card padding
    func cardPadding() -> some View {
        self.padding(.cardPadding)
    }
    
    /// Apply standard section padding
    func sectionPadding() -> some View {
        self.padding(.sectionPadding)
    }
    
    /// Apply compact padding for tight layouts
    func compactPadding() -> some View {
        self.padding(.compactPadding)
    }
    
    /// Apply system horizontal padding (16pt standard)
    func systemHorizontalPadding() -> some View {
        self.padding(.horizontal, .regular)
    }
    
    /// Apply system vertical padding (20pt standard)
    func systemVerticalPadding() -> some View {
        self.padding(.vertical, .medium)
    }
}
