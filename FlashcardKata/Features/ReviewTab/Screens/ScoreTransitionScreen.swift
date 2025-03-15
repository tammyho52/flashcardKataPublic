//
//  ScoreTransitionScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Displays a transition screen showing correct/incorrect message
//  with visual animations after each flashcard is reviewed.

import SwiftUI

struct ScoreTransitionScreen: View {
    @State private var scaleEffect: CGFloat = 1
    @State private var showMessage: Bool = false
    @Binding var reviewViewState: ReviewViewState

    let scoreType: ScoreType

    var body: some View {
        ZStack {
            ForEach(0..<20) { _ in
                IconConfetti(scoreType: scoreType)
            }

            Text(scoreType.message)
                .font(.customLargeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(scoreType.backgroundColor)
                .clipShape(Capsule())
                .opacity(showMessage ? 1 : 0)
                .scaleEffect(scaleEffect)
                .shadow(radius: 5)
                .onAppear {
                    startAnimation()
                }
        }
    }

    private func startAnimation() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            showMessage = true
            scaleEffect = 1.3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeOut(duration: 0.5)) {
                showMessage = false
                scaleEffect = 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            reviewViewState = .flashcard
        }
    }
}

struct IconConfetti: View {
    @State private var xOffset: CGFloat = .random(in: -500...500)
    @State private var yOffset: CGFloat = .random(in: -1000...100)
    @State private var rotation: Double = .random(in: -90...90)

    let scoreType: ScoreType

    var body: some View {
        IconView(scoreType: scoreType)
            .frame(width: 10, height: 20)
            .rotationEffect(.degrees(rotation))
            .offset(x: xOffset, y: yOffset)
            .onAppear {
                withAnimation(.linear(duration: 2.5)) {
                    yOffset = 1000
                    xOffset += .random(in: -250...100)
                }
            }
    }
}

#if DEBUG
#Preview {
    ScoreTransitionScreen(reviewViewState: .constant(.correctMessage), scoreType: .correct)
}

#Preview {
    ScoreTransitionScreen(reviewViewState: .constant(.incorrectMessage), scoreType: .incorrect)
}
#endif
