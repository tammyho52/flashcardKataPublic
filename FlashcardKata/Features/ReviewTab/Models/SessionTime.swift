//
//  SessionTime.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Model representing preset session times for timed review sessions.

import Foundation

/// Represents available session times for timed review sessions.
enum SessionTime: String, CaseIterable, Codable {
    case fiveMinutes = "5 minutes"
    case tenMinutes = "10 minutes"
    case fifteenMinutes = "15 minutes"
    case thirtyMinutes = "30 minutes"
    case oneHour = "1 hour"

    /// Returns the session time in minutes.
    var minutes: Int {
        switch self {
        case .fiveMinutes:
            return 5
        case .tenMinutes:
            return 10
        case .fifteenMinutes:
            return 15
        case .thirtyMinutes:
            return 30
        case .oneHour:
            return 60
        }
    }

    /// Returns the session time in seconds.
    var seconds: Int {
        minutes * 60
    }
}

// Identifiable conformance
extension SessionTime: Identifiable {
    var id: String { rawValue }
}
