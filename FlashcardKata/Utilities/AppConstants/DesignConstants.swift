//
//  DesignConstants.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Central repository for design-related constants in the app.

import SwiftUI

typealias Colors = DesignConstants.Colors
typealias Padding = DesignConstants.Padding

struct DesignConstants {
    static let screenBounds = UIScreen.main.bounds
    static let screenWidth = screenBounds.width
    static let screenHeight = screenBounds.height
    static let debouncerTimeInterval: TimeInterval = 1

    // MARK: - Color Palette
    struct Colors {
        // Text Colors
        static let primaryText = ColorPalette.Text.primary
        static let secondaryText = ColorPalette.Text.secondary
        static let textBackground = ColorPalette.Text.background

        // Button Colors
        static let primaryButtonForeground = ColorPalette.Button.primaryForeground
        static let primaryButtonBackground = ColorPalette.Button.primaryBackground

        static let secondaryButtonForeground = ColorPalette.Button.secondaryForeground
        static let secondaryButtonBackground = ColorPalette.Button.secondaryBackground

        static let buttonDisabled = ColorPalette.Button.disabled
        
        // Other Colors
        static let iconPrimary = ColorPalette.Icon.primary
        static let iconSecondary = ColorPalette.Icon.secondary
        static let tabBarTint = ColorPalette.TabBar.tint
    }

    // MARK: - Layout Constants
    struct Layout {
        static let cornerRadius: CGFloat = 16
        static let opacity: CGFloat = 0.8
    }

    // MARK: - Padding Constants
    struct Padding {
        static let smallVertical: CGFloat = 8
        static let mediumVertical: CGFloat = 16
        static let largeVertical: CGFloat = 20

        static let smallHorizontal: CGFloat = 8
        static let mediumHorizontal: CGFloat = 16
        static let largeHorizontal: CGFloat = 20

        struct Button {
            static let textInset: CGFloat = 12
            static let external: CGFloat = 16
        }

        struct Text {
            static let smallInset: CGFloat = 4
            static let mediumInset: CGFloat = 8
            static let largeInset: CGFloat = 12
        }

        struct Content {
            static let sectionSpacing: CGFloat = 20
            static let itemSpacing: CGFloat = 16
            static let itemInset: CGFloat = 10
            static let edgePadding: CGFloat = 16
        }

        struct Flashcard {
            static let horizontal: CGFloat = 20
            static let vertical: CGFloat = 16
        }
    }

}
