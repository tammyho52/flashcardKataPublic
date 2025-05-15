//
//  Tab.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Model to define the app's tab structure, storing the tab name, associated symbols, and background colors.

import SwiftUI

enum Tab: String, CaseIterable, Codable {
    case decks
    case read
    case kata
    case tracker
    case settings

    var symbol: String {
        switch self {
        case .decks:
            "rectangle.on.rectangle.angled"
        case .read:
            "text.book.closed"
        case .kata:
            "clock"
        case .tracker:
            "mail"
        case .settings:
            "gearshape"
        }
    }

    var backgroundGradientColors: BackgroundGradientColors {
        switch self {
        case .decks:
            return BackgroundGradientColors(
                navigationBarBackground: Color.lightSoftGray,
                backgroundGradientPrimaryColor: Color.darkSoftGray,
                backgroundGradientSecondaryColor: Color.white
            )
        case .read:
            return BackgroundGradientColors(
                navigationBarBackground: Color.darkTeal,
                backgroundGradientPrimaryColor: Color.lightTeal,
                backgroundGradientSecondaryColor: Color.white
            )
        case .kata:
            return BackgroundGradientColors(
                navigationBarBackground: Color.darkBlue,
                backgroundGradientPrimaryColor: Color.lightBlue,
                backgroundGradientSecondaryColor: Color.white
            )
        case .tracker:
            return BackgroundGradientColors(
                navigationBarBackground: Color.darkGreen,
                backgroundGradientPrimaryColor: Color.lightGreen,
                backgroundGradientSecondaryColor: Color.white
            )
        case .settings:
            return BackgroundGradientColors(
                navigationBarBackground: Color.blue.opacity(0.5),
                backgroundGradientPrimaryColor: Color.blue.opacity(0.5),
                backgroundGradientSecondaryColor: Color.white
            )
        }
    }
}
