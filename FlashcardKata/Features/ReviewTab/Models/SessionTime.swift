//
//  SessionTime.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Model representing preset session times.

import Foundation

enum SessionTime: String, Identifiable, CaseIterable, Codable {
    case fiveMinutes = "5 minutes"
    case tenMinutes = "10 minutes"
    case fifteenMinutes = "15 minutes"
    case thirtyMinutes = "30 minutes"
    case oneHour = "1 hour"

    var id: String { rawValue }

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

    var seconds: Int {
        minutes * 60
    }
}
