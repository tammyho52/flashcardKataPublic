//
//  ReviewProgressBar.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A reusable UI component that visually represents the user's progress
//  in a review session.

import SwiftUI

/// Displays a progress bar indicating the user's progress in a review session.
struct ReviewProgressBar: View {
    // MARK: - Properties
    @Binding var currentFlashcardIndex: Int
    
    let totalCardCount: Int
    var progressValue: Double {
        Double(currentFlashcardIndex) / Double(totalCardCount)
    }
    
    // MARK: - Body
    var body: some View {
        HStack {
            Text("\(currentFlashcardIndex) / \(totalCardCount)")
                .fontWeight(.semibold)
                .accessibilityIdentifier("reviewCardCounter")
            ProgressView(value: progressValue)
                .tint(Color.customSecondary)
                .scaleEffect(x: 1, y: 4, anchor: .center)
                .accessibilityIdentifier("reviewProgressLabel")
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 7.5)
        .background(.white.opacity(0.8))
        .clipShape(Capsule())
        .applyCoverShadow()
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ZStack {
        Color.gray
        ReviewProgressBar(
            currentFlashcardIndex: .constant(10),
            totalCardCount: 12
        )
    }
}
#endif
