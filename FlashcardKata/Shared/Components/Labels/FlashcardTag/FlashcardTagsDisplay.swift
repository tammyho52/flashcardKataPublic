//
//  FlashcardLabels.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A view that dynamically displays flashcard tags, adjusting to fit in available space.

import SwiftUI

struct FlashcardTagsDisplay: View {
    var showDifficultyLevel: Bool
    var showDeckName: Bool
    var difficultyLevel: DifficultyLevel
    var deckNameLabel: DeckNameLabel?

    let factory = FlashcardTagLabelFactory()

    var flashcardTags: [(tagType: FlashcardTagType, show: Bool)] {
        var result: [(FlashcardTagType, Bool)] = []
        result.append(
            (.difficultyLevel(difficultyLevel: difficultyLevel),
             showDifficultyLevel)
        )
        if let deckNameLabel {
            result.append(
                (.deckName(deckNameLabel: deckNameLabel),
                showDeckName)
            )
        }
        return result
    }

    var body: some View {
        FlowLayout(spacing: 10) {
            ForEach(flashcardTags.indices, id: \.self) { index in
                if flashcardTags[index].show {
                    factory.createTag(for: flashcardTags[index].tagType)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 20)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    FlashcardTagsDisplay(
        showDifficultyLevel: true,
        showDeckName: true,
        difficultyLevel: DifficultyLevel.medium,
        deckNameLabel: DeckNameLabel.sample
    )
}
#endif
