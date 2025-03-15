//
//  DifficultyLevel.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Enum that represents the difficulty level of a flashcard.

import SwiftUI

enum DifficultyLevel: String, CaseIterable, Codable {
    case easy
    case medium
    case hard
}

extension DifficultyLevel {
    // need to take this out
    var labelColor: Color {
        switch self {
        case .easy: .green
        case .medium: .yellow
        case .hard: .orange
        }
    }
    // Move the capitalized or whole description to view model
    var description: String {
        self.rawValue.capitalized
    }
}
