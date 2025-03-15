//
//  StudyModeTile.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Component that displays a tile representing a review mode, including an icon and description.

import SwiftUI

struct ReviewModeTile: View {
    let symbolName: String
    let description: String

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

#if DEBUG
#Preview {
    HStack {
        ReviewModeTile(symbolName: "rectangle.on.rectangle", description: "Practice")
        ReviewModeTile(symbolName: "rectangle.on.rectangle", description: "Practice")
    }
}
#endif
