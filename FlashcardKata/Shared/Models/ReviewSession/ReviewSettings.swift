//
//  ReviewSettings.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Structure that holds settings for review sessions.

import Foundation

struct ReviewSettings {
    var selectedFlashcardMode: FlashcardMode = .shuffle {
        didSet {
            if selectedFlashcardMode == .shuffle {
                selectedFlashcardIDs.removeAll()
            }
        }
    }
    var displayCardSort: CardSort = .shuffle
    var selectedFlashcardIDs: Set<String> = []
    var showHint = true
    var showDifficultyLevel = true
    var showFlashcardDeckName = true
    var sessionTime: SessionTime?
    var targetCorrectCount: Int?
}

extension ReviewSettings {
    static let reviewTab = ReviewSettings(sessionTime: .fifteenMinutes, targetCorrectCount: 10)
    static let sample = ReviewSettings(showHint: true, showDifficultyLevel: true, showFlashcardDeckName: true)
}
