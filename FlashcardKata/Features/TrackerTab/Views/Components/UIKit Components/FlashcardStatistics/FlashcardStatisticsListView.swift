//
//  FlashcardStatisticsListView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A SwiftUI view that wraps a UIKit view controller to display flashcard statistics in a list format.

import SwiftUI

/// A view that displays flashcard review statistics in a list.
struct FlashcardStatisticsListView: UIViewControllerRepresentable {
    // MARK: - Properties
    @Binding var flashcardReviewStatistics: [FlashcardReviewStatistics]
    let deckTitle: String
    let deckColor: Color
    
    func makeUIViewController(context: Context) -> FlashcardStatisticsViewController {
        let viewController = FlashcardStatisticsViewController()
        viewController.flashcardReviewStatistics = flashcardReviewStatistics
        viewController.deckTitle = deckTitle
        viewController.deckColor = deckColor.uiColor
        return viewController
    }
    
    func updateUIViewController(
        _ uiViewController: FlashcardStatisticsViewController,
        context: Context
    ) {
        uiViewController.flashcardReviewStatistics = flashcardReviewStatistics
        uiViewController.collectionView?.reloadData()
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    FlashcardStatisticsListView(
        flashcardReviewStatistics: .constant(FlashcardReviewStatistics.sampleArray),
        deckTitle: "Test Deck Title",
        deckColor: .darkBlue
    )
}
#endif

