//
//  DeckStatisticsViewController.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This view controller displays deck review statistics, including subdecks.

import UIKit

/// A view controller that displays deck review statistics.
class DeckStatisticsViewController: UIViewController {
    // MARK: - Properties
    var collectionView: UICollectionView?
    var deckWithSubdecksReviewStatistics: [DeckReviewStatistics: [DeckReviewStatistics]] = [:]
    
    var coordinator: DeckStatisticsViewCoordinator?
    var onSelectDeck: ((DeckReviewStatistics) -> Void)?
    
    var sortedParentDecks: [DeckReviewStatistics] {
        return Array(deckWithSubdecksReviewStatistics.keys).sorted(by: { $0.deckName < $1.deckName })
    }
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Deck Review Statistics"
        label.font = boldFont(from: UIFont.customTitle3)
        label.textColor = .customPrimary
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCollectionView()
    }
    
    // MARK: - Methods
    func setCoordinator(_ coordinator: DeckStatisticsViewCoordinator) {
        self.coordinator = coordinator
        collectionView?.dataSource = coordinator
        collectionView?.delegate = coordinator
        self.onSelectDeck = coordinator.onSelectDeckCell
    }
    
    /// Adds and positions the title label in the view.
    private func setupViews() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
    }
    
    /// Sets up the collection view to display deck and subdeck review statistics.
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        guard let collectionView else { return }
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            DeckStatisticsViewCell.self,
            forCellWithReuseIdentifier: DeckStatisticsViewCell.reuseIdentifier
        )
        collectionView.register(
            DeckStatisticsHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DeckStatisticsHeaderView.reusableIdentifier
        )
        collectionView.register(
            DeckStatisticsDividerView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: DeckStatisticsDividerView.reusableIdentifier
        )
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DeckStatisticsViewController: UICollectionViewDelegateFlowLayout {
    /// Provides header or footer views for a given section.
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: DeckStatisticsHeaderView.reusableIdentifier,
                for: indexPath
            ) as! DeckStatisticsHeaderView
            let parentDeck = sortedParentDecks[indexPath.section]
            headerView.configure(with: parentDeck.deckName, textColor: parentDeck.deckColor.uiColor)
            return headerView
        }
        
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: DeckStatisticsDividerView.reusableIdentifier,
                for: indexPath
            ) as! DeckStatisticsDividerView
            let parentDeck = sortedParentDecks[indexPath.section]
            footerView.configure(color: parentDeck.deckColor.uiColor)
            return footerView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width - 20, height: 100)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 41) // 1pt divider + 20pt padding (top & bottom)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension DeckStatisticsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return deckWithSubdecksReviewStatistics.keys.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let parentDeck = sortedParentDecks[section]
        let subdecks = deckWithSubdecksReviewStatistics[parentDeck] ?? []
        return 1 + subdecks.count // One for the parent deck, remainder for subdecks
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let parentDeck = sortedParentDecks[indexPath.section]
        let subdecks = deckWithSubdecksReviewStatistics[parentDeck] ?? []
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DeckStatisticsViewCell.reuseIdentifier,
            for: indexPath
        ) as! DeckStatisticsViewCell
        
        // First item is the parent deck, rest are subdecks
        if indexPath.item == 0 {
            cell.configure(with: parentDeck)
        } else {
            cell.configure(with: subdecks[indexPath.item - 1]) // Subtract 1 to account for parent deck
        }
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard indexPath.section < sortedParentDecks.count else { return }
        let parentDeck = sortedParentDecks[indexPath.section]
        let subDecks = deckWithSubdecksReviewStatistics[parentDeck] ?? []
        
        let selectedDeckReviewStatistics: DeckReviewStatistics
        if indexPath.item == 0 {
            selectedDeckReviewStatistics = parentDeck
        } else if indexPath.item - 1 < subDecks.count {
            selectedDeckReviewStatistics = subDecks[indexPath.item - 1]
        } else {
            return
        }
        
        // Animate the selection of the cell
        if let cell = collectionView.cellForItem(at: indexPath) as? DeckStatisticsViewCell {
            UIView.animate(withDuration: 0.3) {
                cell.contentView.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
            }
        }
        onSelectDeck?(selectedDeckReviewStatistics)
    }
}

// MARK: - DeckStatisticsViewCoordinator
class DeckStatisticsViewCoordinator: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    var deckWithSubdecksReviewStatistics: [DeckReviewStatistics: [DeckReviewStatistics]]
    var onSelectDeckCell: (DeckReviewStatistics) -> Void
    
    var sortedParentDecks: [DeckReviewStatistics] {
        return Array(deckWithSubdecksReviewStatistics.keys).sorted(by: { $0.deckName < $1.deckName })
    }
    
    init(
        deckWithSubdecksReviewStatistics: [DeckReviewStatistics: [DeckReviewStatistics]],
        onSelectDeckCell: @escaping (DeckReviewStatistics) -> Void
    ) {
        self.deckWithSubdecksReviewStatistics = deckWithSubdecksReviewStatistics
        self.onSelectDeckCell = onSelectDeckCell
    }
    
    // MARK: - UICollectionViewDataSource Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return deckWithSubdecksReviewStatistics.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let parentDeck = sortedParentDecks[section]
        let subdecks = deckWithSubdecksReviewStatistics[parentDeck] ?? []
        return 1 + subdecks.count // One for the parent deck, remainder for subdecks
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let parentDeck = sortedParentDecks[indexPath.section]
        let subdecks = deckWithSubdecksReviewStatistics[parentDeck] ?? []
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DeckStatisticsViewCell.reuseIdentifier,
            for: indexPath
        ) as! DeckStatisticsViewCell
        
        if indexPath.item == 0 {
            cell.configure(with: parentDeck)
        } else {
            cell.configure(with: subdecks[indexPath.item - 1]) // Subtract 1 to account for parent deck
        }
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard indexPath.section < sortedParentDecks.count else { return }
        let parentDeck = sortedParentDecks[indexPath.section]
        let subDecks = deckWithSubdecksReviewStatistics[parentDeck] ?? []
        
        let selectedDeckReviewStatistics: DeckReviewStatistics
        if indexPath.item == 0 {
            selectedDeckReviewStatistics = parentDeck
        } else if indexPath.item - 1 < subDecks.count {
            selectedDeckReviewStatistics = subDecks[indexPath.item - 1]
        } else {
            return
        }
        onSelectDeckCell(selectedDeckReviewStatistics)
    }
}

// MARK: - Preview
#if DEBUG
import SwiftUI

struct DeckStatisticsViewControllerPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DeckStatisticsViewController {
        let viewController = DeckStatisticsViewController()
        
        let sampleData = DeckReviewStatistics.sampleDeckWithSubdecksReviewStatistics
        let coordinator = DeckStatisticsViewCoordinator(
            deckWithSubdecksReviewStatistics: sampleData,
            onSelectDeckCell: { _ in }
        )
        
        viewController.setCoordinator(coordinator)
        viewController.deckWithSubdecksReviewStatistics = sampleData
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: DeckStatisticsViewController, context: Context) {
        // Not needed for preview
    }
}

#Preview {
    DeckStatisticsViewControllerPreview()
}

#endif
