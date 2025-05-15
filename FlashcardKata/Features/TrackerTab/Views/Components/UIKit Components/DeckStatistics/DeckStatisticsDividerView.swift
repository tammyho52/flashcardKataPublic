//
//  DeckStatisticsDividerView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This reusable view acts as a horizontal divider used as a footer in the deck statistics collection view.

import UIKit

/// A reusable collection view footer that displays a horizontal divider line.
class DeckStatisticsDividerView: UICollectionReusableView {
    static let reusableIdentifier = "DeckStatisticsDividerView"
    
    private let divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(divider)
        
        NSLayoutConstraint.activate([
            divider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            divider.centerYAnchor.constraint(equalTo: centerYAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError(uiKitFatalErrorMessage(for: "DeckStatisticsDividerView"))
    }
    
    // Set the color of the divider line
    func configure(color: UIColor) {
        divider.backgroundColor = color
    }
}

// MARK: - Preview
#if DEBUG
import SwiftUI

struct DeckStatisticsDividerViewPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> DeckStatisticsDividerView {
        let view = DeckStatisticsDividerView()
        view.configure(color: .customAccent)
        return view
    }
    
    func updateUIView(_ uiView: DeckStatisticsDividerView, context: Context) {
        // No updates needed for preview.
    }
}

#Preview {
    DeckStatisticsDividerViewPreview()
}
#endif
