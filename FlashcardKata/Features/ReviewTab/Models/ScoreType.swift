//
//  ScoreType.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  An enum for tracking score types (correct or incorrect).

import SwiftUI

// Represents the type of score in a review session.
enum ScoreType: String {
    case correct
    case incorrect

    /// Provides a description of the score type.
    var text: String {
        switch self {
        case .correct:
            return "Correct Score"
        case .incorrect:
            return "Incorrect Score"
        }
    }

    /// Provides the corresponding symbol for the score type.
    var symbol: String {
        switch self {
        case .correct:
            ContentConstants.Symbols.correctScore
        case .incorrect:
            ContentConstants.Symbols.incorrectScore
        }
    }

    /// Provides the corresponding message for the score type.
    var message: String {
        switch self {
        case .correct:
            "Good job!"
        case .incorrect:
            "Next time!"
        }
    }

    /// Provides the corresponding color for the score type.
    var backgroundColor: Color {
        switch self {
        case .correct:
            Color.customAccent2
        case .incorrect:
            Color.darkSoftGray
        }
    }
}
