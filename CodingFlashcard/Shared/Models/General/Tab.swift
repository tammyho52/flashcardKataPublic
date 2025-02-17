//
//  Tab.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

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
    
    var backgroundGradientColors: (navigationBarBackground: Color, backgroundGradientPrimaryColor: Color, backgroundGradientSecondaryColor: Color) {
        switch self {
        case .decks:
            return (Color.lightSoftGray, Color.darkSoftGray, Color.white)
        case .read:
            return(Color.darkTeal, Color.lightTeal, Color.white)
        case .kata:
            return(Color.darkBlue, Color.lightBlue, Color.white)
        case .tracker:
            return(Color.darkGreen, Color.lightGreen, Color.white)
        case .settings:
            return(Color.blue.opacity(0.5), Color.blue.opacity(0.5), Color.white)
        }
    }
}
