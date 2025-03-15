//
//  ReadingListView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View to display a horizontal scrollable list of flashcards for reading experience.

import SwiftUI

struct ReadingListView: View {
    @State private var frameWidth: CGFloat = 0
    @State private var frame: CGSize = .zero
    @State private var isEndOfDeck: Bool = false
    @State private var lastFlashcardID: String?
    @State private var showFlippableFlashcardFront = true
    @State private var showStaticFlashcardFront = true
    @State private var showStaticFlashcardBack = false
    @Binding var flashcardLayout: FlashcardLayout
    @Binding var flashcardDisplayModels: [FlashcardDisplayModel]

    var showHint: Bool
    var showDifficultyLevel: Bool
    var showDeckName: Bool

    let cardSpacing: CGFloat = 30

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem()], spacing: cardSpacing) {
                ForEach(flashcardDisplayModels, id: \.flashcard.id) { flashcardDisplayModel in
                    flashcardCardView(for: flashcardDisplayModel)
                        .padding(.vertical, 5)
                        .overlay(alignment: .bottom) {
                            if flashcardDisplayModel.flashcard.id == lastFlashcardID {
                                endOfDeckLabel
                                    .padding(.vertical, 20)
                            }
                        }
                        .visualEffect { content, proxy in
                            content
                                .rotation3DEffect(
                                    .degrees(-proxy.frame(in: .global).minX + cardSpacing) / 8,
                                    axis: (x: 0, y: 1, z: 0)
                                )
                        }
                }
            }
            .padding(.horizontal, cardSpacing)
            .padding(.bottom, 30)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .overlay {
            ViewGeometry()
        }
        .onPreferenceChange(ViewSizeKey.self) { size in
            frameWidth = size.width
            frame = size
        }
        .onAppear {
            lastFlashcardID = flashcardDisplayModels.last?.flashcard.id
        }
        .onChange(of: flashcardDisplayModels) {
            lastFlashcardID = flashcardDisplayModels.last?.flashcard.id
        }
    }

    // MARK: - Child Views
    @ViewBuilder
    private func flashcardCardView(for flashcardDisplayModel: FlashcardDisplayModel) -> some View {
        if flashcardLayout == .frontOnly {
            FlashcardReadingView(
                showFlashcardFront: $showFlippableFlashcardFront,
                flashcardDisplayModel: flashcardDisplayModel,
                showHint: showHint,
                showDifficultyLevel: showDifficultyLevel,
                showDeckName: showDeckName,
                frameWidth: max(0, frameWidth - (cardSpacing * 2))
            )
        } else {
            VStack(spacing: 20) {
                FlashcardReadingView(
                    showFlashcardFront: $showStaticFlashcardFront,
                    flashcardDisplayModel: flashcardDisplayModel,
                    showHint: showHint,
                    showDifficultyLevel: showDifficultyLevel,
                    showDeckName: showDeckName,
                    frameWidth: max(0, frameWidth - (cardSpacing * 2)),
                    isFlippable: false,
                    aspectRatio: 1.2
                )
                FlashcardReadingView(
                    showFlashcardFront: $showStaticFlashcardBack,
                    flashcardDisplayModel: flashcardDisplayModel,
                    showHint: showHint,
                    showDifficultyLevel: showDifficultyLevel,
                    showDeckName: showDeckName,
                    frameWidth: max(0, frameWidth - (cardSpacing * 2)),
                    isFlippable: false,
                    aspectRatio: 1.2
                )
            }
        }
    }

    private var endOfDeckLabel: some View {
        Text("End of Deck")
            .fontWeight(.semibold)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .foregroundStyle(.white)
            .background(Color.customSecondary)
            .clipDefaultShape()
    }
}

#if DEBUG
#Preview {
    ReadingListView(
        flashcardLayout: .constant(.frontOnly),
        flashcardDisplayModels: .constant(FlashcardDisplayModel.sampleArray),
        showHint: true,
        showDifficultyLevel: true,
        showDeckName: true
    )
}

#Preview {
    ReadingListView(
        flashcardLayout: .constant(.frontAndBack),
        flashcardDisplayModels: .constant(FlashcardDisplayModel.sampleArray),
        showHint: false,
        showDifficultyLevel: false,
        showDeckName: false
    )
}
#endif
