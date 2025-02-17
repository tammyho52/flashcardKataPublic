//
//  ReviewProgressBar.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct ReviewProgressBar: View {
    @Binding var currentFlashcardIndex: Int
    let totalCardCount: Int
    
    var progressValue: Double {
        Double(currentFlashcardIndex) / Double(totalCardCount)
    }

    var body: some View {
        HStack {
            Text("\(currentFlashcardIndex) / \(totalCardCount)")
                .fontWeight(.semibold)
            ProgressView(value: progressValue)
                .tint(Color.customSecondary)
                .scaleEffect(x: 1, y: 4, anchor: .center)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 7.5)
        .background(.white.opacity(0.8))
        .clipShape(Capsule())
        .applyCoverShadow()
    }
}

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
