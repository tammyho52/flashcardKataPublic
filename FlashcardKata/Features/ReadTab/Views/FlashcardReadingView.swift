//
//  FlashcardReadingView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View to display a flippable flashcard.

import SwiftUI

struct FlashcardReadingView: View {
    @Binding var showFlashcardFront: Bool
    let flashcardDisplayModel: FlashcardDisplayModel
    var showHint: Bool
    var showDifficultyLevel: Bool
    var showDeckName: Bool
    var frameWidth: CGFloat
    var isFlippable: Bool = true
    var aspectRatio: Double = 0.65

    var body: some View {
        FlashcardCardView(
            showFlashcardFront: $showFlashcardFront,
            flashcard: flashcardDisplayModel.flashcard,
            isFlippable: isFlippable,
            showHint: showHint,
            showDifficultyLevel: showDifficultyLevel,
            showDeckName: showDeckName,
            deckNameLabel: flashcardDisplayModel.deckNameLabel,
            aspectRatio: aspectRatio
        )
        .frame(width: frameWidth)
    }
}

#if DEBUG
#Preview {
    FlashcardReadingView(
        showFlashcardFront: .constant(true),
        flashcardDisplayModel: FlashcardDisplayModel.sample,
        showHint: true,
        showDifficultyLevel: true,
        showDeckName: true,
        frameWidth: 300
    )
}
#endif
