//
//  CombinedGradient.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view that creates a soft gradient used for backgrounds.

import SwiftUI

/// A view that creates a soft gradient background using a combination of linear and radial gradients.
struct SoftGradient: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    .customAccent.opacity(0.8), .customAccent2.opacity(0.8), .customAccent3.opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.9),
                    Color.clear
                ]),
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 200
            )
            .blendMode(.overlay)
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    RoundedRectangle(cornerRadius: 20)
        .foregroundStyle(.clear)
        .frame(width: 250, height: 250)
        .background(SoftGradient())
        .clipDefaultShape()
}
#endif
