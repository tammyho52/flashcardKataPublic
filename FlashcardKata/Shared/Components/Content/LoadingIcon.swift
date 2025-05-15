//
//  LoadingIconView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Custom progress view that represents a loading state.

import SwiftUI

struct LoadingIcon: View {
    @State private var isRotating = false

    var body: some View {
        Image(systemName: "circle.hexagonpath")
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
            .foregroundStyle(iconGradient)
            .rotationEffect(.degrees(isRotating ? 360 : 0), anchor: .center)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isRotating = true
                }
            }
    }

    private var iconGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.customAccent, Color.customAccent2, Color.customAccent3,
                Color.customAccent2, Color.customAccent
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    LoadingIcon()
}
#endif
