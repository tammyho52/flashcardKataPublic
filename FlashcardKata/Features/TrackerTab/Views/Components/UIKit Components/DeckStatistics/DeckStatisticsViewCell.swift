//
//  DeckStatisticsViewCell.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A custom collection view cell that displays deck review statistics including the deck name, review statistics, and a progress bar.

import UIKit

/// A collection view cell displaying a deck's review statistics.
class DeckStatisticsViewCell: UICollectionViewCell {
    static let reuseIdentifier = "DeckStatisticsCell"
    
    private let deckNameLabel = UILabel()
    private let statisticsLabel = UILabel()
    
    /// A custom progress view to display the progress of the deck review.
    private let progressBar = CustomMarkerProgressView(
        frame: .zero,
        progress: 0,
        progressColor: .white.withAlphaComponent(0.9)
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        self.applyDefaultShadowToLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError(uiKitFatalErrorMessage(for: "DeckStatisticsViewCell"))
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        setupLabels()
        setupStackViews()
        setupContentView()
    }
    
    private func setupLabels() {
        let metrics = UIFontMetrics(forTextStyle: .body)
        
        deckNameLabel.font = metrics.scaledFont(for: boldFont(from: UIFont.customBody))
        deckNameLabel.adjustsFontForContentSizeCategory = true
        deckNameLabel.numberOfLines = 1
        deckNameLabel.lineBreakMode = .byTruncatingTail
        
        statisticsLabel.font = metrics.scaledFont(for: boldFont(from: UIFont.customBody))
        statisticsLabel.adjustsFontForContentSizeCategory = true
    }
    
    private func setupStackViews() {
        let horizontalStackView = UIStackView(arrangedSubviews: [progressBar, statisticsLabel])
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 50
        horizontalStackView.distribution = .fill
        horizontalStackView.alignment = .center
        
        progressBar.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let verticalStackView = UIStackView(arrangedSubviews: [deckNameLabel, horizontalStackView])
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 10
        verticalStackView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        verticalStackView.isLayoutMarginsRelativeArrangement = true
        
        contentView.addSubview(verticalStackView)
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
    
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            verticalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            statisticsLabel.heightAnchor.constraint(equalTo: progressBar.heightAnchor),
        ])
    }
    
    private func setupContentView() {
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }
    
    // MARK: - Configuration
    /// Configures the cell with the provided deck statistics.
    func configure(with deckStatistics: DeckReviewStatistics) {
        deckNameLabel.text = deckStatistics.deckName
        statisticsLabel.text = deckStatistics.reviewText
        
        [deckNameLabel, statisticsLabel].forEach { label in
            label.textColor = .white
        }
        
        progressBar.setProgress(deckStatistics.progressPercentage, animated: true)
        contentView.layer.backgroundColor = deckStatistics.deckColor.uiColor.cgColor
    }
}

// MARK: - Preview
#if DEBUG
import SwiftUI

struct DeckStatisticsViewCellPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 400, height: 100)
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(DeckStatisticsViewCell.self, forCellWithReuseIdentifier: DeckStatisticsViewCell.reuseIdentifier)
        collectionView.dataSource = context.coordinator
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        viewController.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Not needed for preview.
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource {
        func collectionView(
            _ collectionView: UICollectionView,
            numberOfItemsInSection section: Int
        ) -> Int {
            return 1
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DeckStatisticsViewCell.reuseIdentifier,
                for: indexPath
            ) as! DeckStatisticsViewCell
            let mockStatistics = DeckReviewStatistics.sampleArray[0]
            cell.configure(with: mockStatistics)
            return cell
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
}

#Preview {
   DeckStatisticsViewCellPreview()
}
#endif
