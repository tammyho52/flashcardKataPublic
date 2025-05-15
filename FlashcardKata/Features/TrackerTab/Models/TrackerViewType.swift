//
//  TrackerViewType.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This enum defines the types of tracker summary views.

import Foundation

/// Enum representing different types of tracker summary views.
enum TrackerViewType: CaseIterable {
    case dailySummary
    case deckStatistics
    
    /// Returns a user-friendly description of the view type.
    var description: String {
        switch self {
        case .dailySummary:
            "Daily Summary"
        case .deckStatistics:
            "Deck Statistics"
        }
    }
}
