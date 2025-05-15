//
//  FlashcardTextFieldView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view displays a draggable flashcard that can be dragged left or
//  right to indicate whether the user got the answer correct or incorrect.

import SwiftUI

/// A view that displays a draggable flashcard for users to indicate whether they answered the question correctly or incorrectly..
struct DraggableFlashcardView: View {
    // MARK: - Properties
    @State private var showFlashcardFront: Bool = true
    @State private var translation: CGSize = CGSize(width: 0, height: 0) // Tracks user's drag gesture translation.
    @Binding var viewState: ReviewViewState

    var flashcardDisplayModel: FlashcardDisplayModel
    var reviewSettings: ReviewSettings
    var correctScoreAction: () -> Void
    var incorrectScoreAction: () -> Void
    
    // MARK: - Body
    var body: some View {
        FlashcardCardView(
            showFlashcardFront: $showFlashcardFront,
            isFlippable: true,
            flashcard: flashcardDisplayModel.flashcard,
            reviewSettings: reviewSettings,
            deckNameLabel: flashcardDisplayModel.deckNameLabel,
            aspectRatio: 0.75
        )
        .offset(x: translation.width, y: translation.height) // Applies the translation offset to the flashcard.
        // Sets dragging gesture as high priority to ensure it takes precedence.
        .highPriorityGesture(
            DragGesture(minimumDistance: 1, coordinateSpace: .global)
                .onChanged { value in
                    translation = value.translation
                }
                .onEnded { _ in
                    // Represents correct score if user drags right.
                    if translation.width > 5 {
                        correctScoreAction()
                        translation = .zero
                    // Represents inccorrect score if user drags left.
                    } else if translation.width < -5 {
                        incorrectScoreAction()
                        translation = .zero
                    } else {
                        // Resets translation if the drag is too small.
                        translation = .zero
                    }
                }
        )
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    DraggableFlashcardView(
        viewState: .constant(.flashcard),
        flashcardDisplayModel: FlashcardDisplayModel.sample,
        reviewSettings: ReviewSettings(),
        correctScoreAction: {},
        incorrectScoreAction: {}
    )
}
#endif
