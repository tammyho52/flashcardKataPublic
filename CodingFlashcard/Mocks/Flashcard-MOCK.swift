//
//  Flashcard-MOCK.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

#if DEBUG
extension Flashcard {
    static let sampleFlashcard = MockData.flashcardData[0]
    static let sampleFlashcardArray = MockData.flashcardData
    static let sampleFlashcardsByDeckID = MockData.flashcardsByDeckID
}
        
#endif
