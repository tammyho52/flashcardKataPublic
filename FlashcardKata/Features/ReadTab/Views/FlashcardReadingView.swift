//
//  FlashcardReadingView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view to display a flippable flashcard with customizable options such as hints, difficulty level, and deck name.

import SwiftUI

/// A view for displaying a single flashcard with optional flipping functionality.
struct FlashcardReadingView: View {
    // MARK: - Properties
    @Binding var showFlashcardFront: Bool
    let flashcardDisplayModel: FlashcardDisplayModel
    var showHint: Bool
    var showDifficultyLevel: Bool
    var showDeckName: Bool
    var frameWidth: CGFloat
    var isFlippable: Bool = true
    var aspectRatio: Double = 0.65

    // MARK: - Body
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

// MARK: - Preview
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
