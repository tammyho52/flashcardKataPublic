//
//  ReviewMode.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Model representing the four available review modes.

import SwiftUI

enum ReviewMode: String, Hashable, Codable, CaseIterable {
    case practice = "Practice"
    case target = "Target"
    case timed = "Timed"
    case streak = "Streak"

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

extension ReviewMode: Identifiable {
    var id: String {
        return self.rawValue
    }
}
