//
//  FlashcardStatisticsViewController.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  ViewController that displays statistics for flashcard reviews.

import UIKit

/// This view controller displays a collection of flashcard review statistics for the selected deck.
class FlashcardStatisticsViewController: UIViewController {
    // MARK: - Properties
    var collectionView: UICollectionView?
    var flashcardReviewStatistics: [FlashcardReviewStatistics] = []
    var deckTitle: String = ""
    var deckColor: UIColor = .black
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = boldFont(from: UIFont.customTitle3)
        label.textColor = .customPrimary
        label.textAlignment = .center
        return label
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCollectionView()
    }
    
    private func setupViews() {
        titleLabel.text = deckTitle
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
        ])
    }
    
    /// Sets up the collection view to display flashcard review statistics.
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        guard let collectionView else { return }
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FlashcardStatisticsViewCell.self, forCellWithReuseIdentifier: FlashcardStatisticsViewCell.reuseIdentifier)
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension FlashcardStatisticsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    /// Returns the number of sections in the collection view.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return flashcardReviewStatistics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 // Each section displays one cell.
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FlashcardStatisticsViewCell.reuseIdentifier,
            for: indexPath
        ) as! FlashcardStatisticsViewCell
        
        cell.configure(with: flashcardReviewStatistics[indexPath.section], deckColor: deckColor)
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width - 50
        let contentHeight: CGFloat = calculateDynamicHeight(for: flashcardReviewStatistics[indexPath.section])
        return CGSize(width: width, height: contentHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    // MARK: - Private Methods
    /// Calculates a dynamic height for a collection view cell based on its content.
    private func calculateDynamicHeight(for statistics: FlashcardReviewStatistics) -> CGFloat {
        let baseHeight: CGFloat = 100
        
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = " "
        let labelSize = label.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 20, height: CGFloat.greatestFiniteMagnitude))
        let lineHeight = labelSize.height
        let dynamicHeight = baseHeight + lineHeight * 3
        return dynamicHeight
    }
}


