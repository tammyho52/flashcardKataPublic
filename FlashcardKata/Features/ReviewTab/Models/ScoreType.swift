//
//  ScoreType.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Defines an enum for tracking score types (correct or incorrect).

import SwiftUI

enum ScoreType: String {
    case correct
    case incorrect

    var text: String {
        switch self {
        case .correct:
            return "Correct Score"
        case .incorrect:
            return "Incorrect Score"
        }
    }

    var symbol: String {
        switch self {
        case .correct:
            "hand.thumbsup.fill"
        case .incorrect:
            "hand.thumbsdown.fill"
        }
    }

    var message: String {
        switch self {
        case .correct:
            "Good job!"
        case .incorrect:
            "Next time!"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .correct:
            Color.customAccent2
        case .incorrect:
            Color.darkSoftGray
        }
    }
}
