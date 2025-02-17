//
//  FlashcardTextFieldView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct DraggableFlashcardView: View {
    @State var showFlashcardFront: Bool = true
    @State var translation: CGSize = CGSize(width: 0, height: 0)
    @Binding var viewState: ReviewViewState
    
    var flashcardDisplayModel: FlashcardDisplayModel
    var reviewSettings: ReviewSettings
    var correctScoreAction: () -> Void
    var incorrectScoreAction: () -> Void
   
    var body: some View {
        FlashcardCardView(
            showFlashcardFront: $showFlashcardFront,
            isFlippable: true,
            flashcard: flashcardDisplayModel.flashcard,
            reviewSettings: reviewSettings,
            deckNameLabel: flashcardDisplayModel.deckNameLabel,
            aspectRatio: 0.75
        )
        .offset(x: translation.width, y: translation.height)
        .highPriorityGesture(
            DragGesture(minimumDistance: 1, coordinateSpace: .global)
                .onChanged { value in
                    translation = value.translation
                }
                .onEnded { value in
                    if translation.width > 5 {
                        correctScoreAction()
                        translation = .zero
                    } else if translation.width < -5 {
                        incorrectScoreAction()
                        translation = .zero
                    } else {
                        translation = .zero
                    }
                }
        )
    }
}

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
