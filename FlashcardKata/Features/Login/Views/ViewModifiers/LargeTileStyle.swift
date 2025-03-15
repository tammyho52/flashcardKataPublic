//
//  LargeTileStyle.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Modifier to apply icon tile style for app title.

import SwiftUI

struct IconTileStyle: ViewModifier {

    var width: CGFloat
    var height: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [Color.customSecondary, Color.customAccent, Color.customAccent2],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipDefaultShape()
            .overlay(
                RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius)
                    .stroke(.white, lineWidth: 2.5)
            )
            .applyCoverShadow()
    }
}

extension View {
    func applyIconTileStyle(width: CGFloat, height: CGFloat) -> some View {
        self.modifier(IconTileStyle(width: width, height: height))
    }
}

#if DEBUG
#Preview {
    Image(systemName: "person")
        .padding()
        .background(Color.customSecondary)
        .clipDefaultShape()
        .applyIconTileStyle(width: 50, height: 50)
}
#endif
