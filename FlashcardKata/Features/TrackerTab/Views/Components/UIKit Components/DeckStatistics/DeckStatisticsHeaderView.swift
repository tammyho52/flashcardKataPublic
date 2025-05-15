//
//  DeckStatisticsHeaderView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A reusable collection view header that displays a section title.

import UIKit

/// A reusable header view for displaying section titles in the deck statistics collection view.
class DeckStatisticsHeaderView: UICollectionReusableView {
    static let reusableIdentifier = "DeckStatisticsHeaderView"
    
    /// The title label for the header view.
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: boldFont(from: .customHeadline))
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError(uiKitFatalErrorMessage(for: "DeckStatisticsHeaderView"))
    }
    
    // Setup the header view with a title and text color.
    func configure(with title: String, textColor: UIColor) {
        titleLabel.text = title
        titleLabel.textColor = textColor
    }
}

// MARK: - Preview
#if DEBUG
import SwiftUI

struct DeckStatisticsHeaderViewPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> DeckStatisticsHeaderView {
        let view = DeckStatisticsHeaderView()
        view.configure(with: "Sample Title", textColor: .customAccent)
        return view
    }
    
    func updateUIView(_ uiView: DeckStatisticsHeaderView, context: Context) {
        // No updates needed for preview.
    }
}

#Preview {
    DeckStatisticsHeaderViewPreview()
}

#endif
