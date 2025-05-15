//
//  FlashcardStatisticsViewCell.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Custom collection view cell used to display flashcard review statistics.

import UIKit
import SwiftUI

/// A custom cell that displays the review statistics of a single flashcard, including name, review count, and accuracy breakdown.
class FlashcardStatisticsViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let reuseIdentifier = "FlashcardStatisticsCell"
    
    private let flashcardNameLabel = UILabel()
    private let totalReviewTimesLabel = UILabel()
    private let correctCountLabel = UILabel()
    private let incorrectCountLabel = UILabel()
    
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(uiKitFatalErrorMessage(for: "FlashcardStatisticsViewCell"))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if gradientLayer?.frame != contentView.bounds {
            gradientLayer?.frame = contentView.bounds
        }
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        setupLabels()
        setupStackViews()
        setupContentView()
        self.applyDefaultShadowToLayer()
    }
    
    private func setupLabels() {
        let metrics = UIFontMetrics(forTextStyle: .body)
        
        flashcardNameLabel.font = metrics.scaledFont(for: boldFont(from: UIFont.customBody))
        flashcardNameLabel.adjustsFontForContentSizeCategory = true
        flashcardNameLabel.numberOfLines = 3
        flashcardNameLabel.lineBreakMode = .byTruncatingTail
        let lineHeight = flashcardNameLabel.font.lineHeight
        flashcardNameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        flashcardNameLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: lineHeight * 3).isActive = true
        
        totalReviewTimesLabel.font = metrics.scaledFont(for: boldFont(from: UIFont.customBody))
        totalReviewTimesLabel.adjustsFontForContentSizeCategory = true
        totalReviewTimesLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        totalReviewTimesLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        correctCountLabel.font = metrics.scaledFont(for: boldFont(from: UIFont.customBody))
        correctCountLabel.textColor = .systemGreen
        correctCountLabel.adjustsFontForContentSizeCategory = true
        correctCountLabel.setContentHuggingPriority(.required, for: .horizontal)
        correctCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        incorrectCountLabel.font = metrics.scaledFont(for: boldFont(from: UIFont.customBody))
        incorrectCountLabel.adjustsFontForContentSizeCategory = true
        incorrectCountLabel.setContentHuggingPriority(.required, for: .horizontal)
        incorrectCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private func setupStackViews() {
        let horizontalStackView = UIStackView(arrangedSubviews: [totalReviewTimesLabel, correctCountLabel, incorrectCountLabel])
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 10
        horizontalStackView.distribution = .fill
        horizontalStackView.alignment = .center
        horizontalStackView.isLayoutMarginsRelativeArrangement = true
        
        let verticalStackView = UIStackView(arrangedSubviews: [flashcardNameLabel, horizontalStackView])
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
        ])
    }
    
    private func setupContentView() {
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 2.5
        contentView.layer.masksToBounds = true
    }
    
    // MARK: - Configuration
    /// Configures the cell with the provided flashcard statistics and deck color.
    func configure(
        with flashcardStatistics: FlashcardReviewStatistics,
        deckColor: UIColor
    ) {
        flashcardNameLabel.text = flashcardStatistics.frontText
        totalReviewTimesLabel.setSFSymbolWithText(
            symbolName: ContentConstants.Symbols.repeatCount,
            text: "\(flashcardStatistics.totalReviewCount) Reviews",
            textColor: Color.black.uiColor
        )
        correctCountLabel.setSFSymbolWithText(
            symbolName: ContentConstants.Symbols.correctScore,
            text: String(format: "%.0f%%", flashcardStatistics.correctPercentage),
            textColor: Color.green.uiColor
        )
        incorrectCountLabel.setSFSymbolWithText(
            symbolName: ContentConstants.Symbols.incorrectScore,
            text: String(format: "%.0f%%", flashcardStatistics.incorrectPercentage),
            textColor: Color.orange.uiColor
        )
        
        if self.gradientLayer == nil {
            setupGradientBackground(color: deckColor)
        }
        contentView.layer.borderColor = deckColor.cgColor
    }
    
    // MARK: - Private Methods
    /// Sets up the gradient background for the cell.
    private func setupGradientBackground(color: UIColor) {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.colors = [
            color.cgColor,
            UIColor.white.cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        contentView.layer.insertSublayer(gradientLayer, at: 0)
        self.gradientLayer = gradientLayer
    }
}

#if DEBUG
import SwiftUI

struct FlashcardStatisticsViewCellPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 300, height: 150)
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(FlashcardStatisticsViewCell.self, forCellWithReuseIdentifier: FlashcardStatisticsViewCell.reuseIdentifier)
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
                withReuseIdentifier: FlashcardStatisticsViewCell.reuseIdentifier,
                for: indexPath
            ) as! FlashcardStatisticsViewCell
            let mockStatistics = FlashcardReviewStatistics.sample
            cell.configure(with: mockStatistics, deckColor: .darkBlue)
            return cell
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
}

// MARK: - Preview
#Preview {
   FlashcardStatisticsViewCellPreview()
}
#endif
