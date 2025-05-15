//
//  DeckStatisticsView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A view that displays card review statistics for decks and their subdecks.

import SwiftUI

/// A view that displays card review progress for decks and their subdecks.
struct DeckStatisticsListView: UIViewControllerRepresentable {
    // MARK: - Properties
    @Binding var deckWithSubdecksReviewStatistics: [DeckReviewStatistics: [DeckReviewStatistics]]
    
    let onSelectDeckCell: (DeckReviewStatistics) -> Void
    
    // MARK: - Coordinator
    /// A coordinator that manages the interaction between the SwiftUI view and the UIKit view controller.
    func makeCoordinator() -> DeckStatisticsViewCoordinator {
        DeckStatisticsViewCoordinator(
            deckWithSubdecksReviewStatistics: deckWithSubdecksReviewStatistics,
            onSelectDeckCell: onSelectDeckCell
        )
    }
    
    // MARK: - UIViewControllerRepresentable Methods
    /// Creates a new instance of `DeckStatisticsViewController`.
    func makeUIViewController(context: Context) -> DeckStatisticsViewController {
        let viewController = DeckStatisticsViewController()
        viewController.deckWithSubdecksReviewStatistics = deckWithSubdecksReviewStatistics
        viewController.setCoordinator(context.coordinator)
        return viewController
    }
    
    /// Updates the `DeckStatisticsViewController` with new data.
    func updateUIViewController(
        _ uiViewController: DeckStatisticsViewController,
        context: Context
    ) {
        uiViewController.deckWithSubdecksReviewStatistics = deckWithSubdecksReviewStatistics
        context.coordinator.deckWithSubdecksReviewStatistics = deckWithSubdecksReviewStatistics
        uiViewController.collectionView?.reloadData()
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    DeckStatisticsListView(
        deckWithSubdecksReviewStatistics: .constant(DeckReviewStatistics.sampleDeckWithSubdecksReviewStatistics),
        onSelectDeckCell: { _ in }
    )
}
#endif
