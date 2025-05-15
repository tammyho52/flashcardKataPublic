//
//  FlashcardTagFactory.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A factory protocol for creating flashcard tags based on the tag type.

import SwiftUI

enum FlashcardTagType {
    case difficultyLevel(difficultyLevel: DifficultyLevel)
    case deckName(deckNameLabel: DeckNameLabel)
}

protocol FlashcardTagFactory {
    associatedtype FlashcardTag: View
    func createTag(for flashcardTagType: FlashcardTagType) -> FlashcardTag
}

struct FlashcardTagLabelFactory: FlashcardTagFactory {
    func createTag(for flashcardTagType: FlashcardTagType) -> some View {
        switch flashcardTagType {
        case .difficultyLevel(let difficultyLevel):
            return FlashcardTagView(
                text: difficultyLevel.description,
                symbolName: ContentConstants.Symbols.difficultyLevel,
                foregroundColor: .black,
                backgroundColor: difficultyLevel.labelColor
            )
        case .deckName(let deckNameLabel):
            return FlashcardTagView(
                text: deckNameLabel.name,
                symbolName: ContentConstants.Symbols.deck,
                foregroundColor: deckNameLabel.isSubDeck ? .black : .white,
                backgroundColor: deckNameLabel.isSubDeck
                    ? deckNameLabel.theme.secondaryColor
                    : deckNameLabel.theme.primaryColor,
                useLightVariant: deckNameLabel.isSubDeck
            )
        }
    }
}
