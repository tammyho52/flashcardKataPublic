//
//  StudyModeTile.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A reusable UI component that represents a review mode selection tile button.

import SwiftUI

/// A view that represents a tile for selecting a review mode.
struct ReviewModeTile: View {
    // MARK: - Properties
    let symbolName: String // The name of the system image to display on the tile.
    let description: String // The description text to display on the tile.

    // MARK: - Body
    var body: some View {
        VStack(spacing: 5) {
            Spacer()
            Image(systemName: symbolName)
                .font(.custom("Avenir", size: 40))
                .foregroundStyle(Color.customPrimary)
                .padding(.top, 10)
            Spacer()
            Text(description)
                .padding(.vertical, 15)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .font(.customHeadline)
        }
        .fontWeight(.semibold)
        .frame(maxWidth: .infinity)
        .aspectRatio(1.3, contentMode: .fit)
        .background(SoftGradient())
        .clipDefaultShape()
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    HStack {
        ReviewModeTile(
            symbolName: ReviewMode.practice.symbolName,
            description: ReviewMode.practice.description
        )
        ReviewModeTile(
            symbolName: ReviewMode.timed.symbolName,
            description: ReviewMode.timed.description
        )
    }
}
#endif
