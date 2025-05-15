//
//  Theme.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A model for deck and subdeck theme colors.

import SwiftUI

enum Theme: String, CaseIterable, Codable {
    case blue
    case slateBlue
    case green
    case orange
    case pink
    case purple
    case red
    case teal
    case yellow
    case gray

    var primaryColor: Color {
        switch self {
        case .blue:
            ColorPalette.Theme.darkBlue
        case .slateBlue:
            ColorPalette.Theme.darkSlateBlue
        case .green:
            ColorPalette.Theme.darkGreen
        case .orange:
            ColorPalette.Theme.darkOrange
        case .pink:
            ColorPalette.Theme.darkPink
        case .purple:
            ColorPalette.Theme.darkPurple
        case .red:
            ColorPalette.Theme.darkRed
        case .teal:
            ColorPalette.Theme.darkTeal
        case .yellow:
            ColorPalette.Theme.darkYellow
        case .gray:
            ColorPalette.Theme.darkGray
        }
    }

    var secondaryColor: Color {
        switch self {
        case .blue:
            ColorPalette.Theme.lightBlue
        case .slateBlue:
            ColorPalette.Theme.lightSlateBlue
        case .green:
            ColorPalette.Theme.lightGreen
        case .orange:
            ColorPalette.Theme.lightOrange
        case .pink:
            ColorPalette.Theme.lightPink
        case .purple:
            ColorPalette.Theme.lightPurple
        case .red:
            ColorPalette.Theme.lightRed
        case .teal:
            ColorPalette.Theme.lightTeal
        case .yellow:
            ColorPalette.Theme.lightYellow
        case .gray:
            ColorPalette.Theme.lightGray
        }
    }

    var colorName: String {
        switch self {
        case .slateBlue:
            return "Slate Blue"
        default:
            return self.rawValue.capitalized
        }
    }
}
