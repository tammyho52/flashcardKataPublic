//
//  ReviewMode.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Model representing the available review modes for review sessions.

import SwiftUI

/// Represents the different modes available for reviewing flashcards.
enum ReviewMode: String, Hashable, Codable, CaseIterable {
    case practice = "Practice"
    case target = "Target"
    case timed = "Timed"
    case streak = "Streak"

    /// Provides a description for each review mode.
    var description: String {
        switch self {
        case .practice:
            "Practice"
        case .target:
            "Target"
        case .timed:
            "Timed"
        case .streak:
            "Streak"
        }
    }
    
    /// Provides a symbol name for each review mode to be used in UI elements.
    var symbolName: String {
        switch self {
        case .practice:
            "rectangle.on.rectangle"
        case .target:
            "target"
        case .timed:
            "timer"
        case .streak:
            "flame"
        }
    }

    /// Provides a color associated with each review mode for UI representation.
    var color: Color {
        switch self {
        case .practice:
            return .green
        case .target:
            return .blue
        case .timed:
            return .brown
        case .streak:
            return .orange
        }
    }
}

// Identifiable conformance for ReviewMode
extension ReviewMode: Identifiable {
    var id: String {
        return self.rawValue
    }
}
