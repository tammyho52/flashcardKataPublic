//
//  TrackerStatistic.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

enum TrackerStatistic {
    case streak(Int)
    case flashcard(Int)
    case time(String)
    
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
    
    var value: String {
        switch self {
        case .streak(let count), .flashcard(let count):
            return "\(count)"
        case .time(let time):
            return time
        }
    }
    
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
