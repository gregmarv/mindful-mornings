//
//  Theme.swift
//  Mindful Mornings
//
//  Design system: calming, optimistic, minimalist
//

import SwiftUI

// MARK: - Color Palette
// Each color provides both light and dark mode variants via UIColor dynamic provider.

extension Color {
    // Primary – soft sage green
    static let mmPrimary = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.52, green: 0.76, blue: 0.65, alpha: 1)   // slightly brighter on dark
            : UIColor(red: 0.47, green: 0.68, blue: 0.58, alpha: 1)
    })

    // Primary dark – for pressed/emphasis states
    static let mmPrimaryDark = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.42, green: 0.66, blue: 0.55, alpha: 1)
            : UIColor(red: 0.37, green: 0.58, blue: 0.48, alpha: 1)
    })

    // Accent – warm amber/gold
    static let mmAccent = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.96, green: 0.80, blue: 0.48, alpha: 1)   // slightly warmer/brighter
            : UIColor(red: 0.91, green: 0.74, blue: 0.41, alpha: 1)
    })

    // Background – warm off-white / deep warm charcoal
    static let mmBackground = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.10, green: 0.10, blue: 0.09, alpha: 1)
            : UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1)
    })

    // Card background
    static let mmCard = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.16, green: 0.16, blue: 0.15, alpha: 1)
            : UIColor(red: 0.95, green: 0.94, blue: 0.91, alpha: 1)
    })

    // Text primary
    static let mmText = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.93, green: 0.92, blue: 0.90, alpha: 1)
            : UIColor(red: 0.22, green: 0.24, blue: 0.26, alpha: 1)
    })

    // Text secondary
    static let mmTextSecondary = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.58, green: 0.58, blue: 0.57, alpha: 1)
            : UIColor(red: 0.50, green: 0.52, blue: 0.54, alpha: 1)
    })

    // Subtle border/divider
    static let mmDivider = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.26, green: 0.26, blue: 0.25, alpha: 1)
            : UIColor(red: 0.88, green: 0.87, blue: 0.84, alpha: 1)
    })

    // Success green
    static let mmSuccess = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.50, green: 0.78, blue: 0.57, alpha: 1)
            : UIColor(red: 0.47, green: 0.72, blue: 0.53, alpha: 1)
    })
}

// MARK: - Reusable Button Styles

struct MMPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(configuration.isPressed ? Color.mmPrimaryDark : Color.mmPrimary)
            )
    }
}

struct MMSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.mmPrimary)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.mmPrimary, lineWidth: 1.5)
            )
    }
}

// MARK: - Reusable Text Field Style

struct MMTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.mmCard)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.mmDivider, lineWidth: 1)
            )
    }
}

extension View {
    func mmTextField() -> some View {
        modifier(MMTextFieldStyle())
    }
}
