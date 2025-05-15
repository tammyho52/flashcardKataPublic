//
//  Flashcard-MOCK.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Generates mock data for flashcards.

import Foundation

#if DEBUG
extension Flashcard {
    static let sampleFlashcard = MockData.flashcardData[0]
    static let sampleFlashcard2 = MockData.flashcard18
    static let sampleFlashcardArray = MockData.flashcardData
    static let sampleFlashcardsByDeckID = MockData.flashcardsByDeckID
}

#endif
