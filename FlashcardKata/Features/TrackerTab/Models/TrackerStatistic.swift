//
//  TrackerStatistic.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This enum represents the type of tracker statistic to display in the summary statistics.

import SwiftUI

/// An enum representing the type of tracker statistic to display in the summary statistics.
enum TrackerStatistic {
    case streak(Int) // Represents the streak count.
    case flashcard(Int) // Represents the flashcard count.
    case time(String) // Represents the time studied.
    
    /// Returns the symbol name associated with the tracker statistic.
    var symbolName: String {
        switch self {
        case .streak:
            return "flame"
        case .flashcard:
            return ContentConstants.Symbols.flashcard
        case .time:
            return "clock"
        }
    }

    /// Returns the value associated with the tracker statistic.
    var value: String {
        switch self {
        case .streak(let count), .flashcard(let count):
            return "\(count)"
        case .time(let time):
            return time
        }
    }

    /// Returns the unit associated with the tracker statistic.
    var unit: String {
        switch self {
        case .streak:
            return "Day Streak"
        case .flashcard(let count):
            return count == 1 ? "Flashcard" : "Flashcards"
        case .time:
            return "Time"
        }
    }

    /// Returns the icon background color associated with the tracker statistic.
    var iconBackgroundColor: Color {
        switch self {
        case .streak:
            return Color.darkBlue
        case .flashcard:
            return Color.darkGreen
        case .time:
            return Color.darkYellow
        }
    }

    /// Returns the background color associated with the tracker statistic.
    var backgroundColor: Color {
        switch self {
        case .streak:
            return Color.lightBlue
        case .flashcard:
            return Color.lightGreen
        case .time:
            return Color.lightYellow
        }
    }
}
