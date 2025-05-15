//
//  ScoreTransitionScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view that displays a transition screen with animations to indicate
//  whether the user's answer was correct or incorrect. Includes confetti
//  effects and a message that animates in and out.

import SwiftUI

/// A view that shows a transition screen with animations for correct/incorrect feedback.
struct ScoreTransitionScreen: View {
    // MARK: - Properties
    @State private var scaleEffect: CGFloat = 1 // Scale effect for the message.
    @State private var showMessage: Bool = false
    @Binding var reviewViewState: ReviewViewState

    let scoreType: ScoreType // The type of score (correct/incorrect) to display.
    
    // MARK: - Body
    var body: some View {
        ZStack {
            ForEach(0..<20) { _ in
                IconConfetti(scoreType: scoreType)
            }
            scoreMessage
        }
    }
    
    // MARK: - Private Views and Methods
    /// Displays the score message with animation.
    private var scoreMessage: some View {
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
    
    /// Starts the animation sequence for the score message.
    private func startAnimation() {
        // Animate the message in with a scale effect.
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            showMessage = true
            scaleEffect = 1.3
        }
        
        // Animate the message out after a delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeOut(duration: 0.5)) {
                showMessage = false
                scaleEffect = 1
            }
        }
        
        // Change the review view state after the message disappears.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            reviewViewState = .flashcard
        }
    }
}

// MARK: - IconConfetti View
/// A view that displays a confetti icon with random movement and rotation.
struct IconConfetti: View {
    @State private var xOffset: CGFloat = .random(in: -500...500)
    @State private var yOffset: CGFloat = .random(in: -1000...100)
    @State private var rotation: Double = .random(in: -90...90)

    let scoreType: ScoreType // The type of score (correct/incorrect) to display.

    var body: some View {
        IconView(scoreType: scoreType)
            .frame(width: 10, height: 20)
            .rotationEffect(.degrees(rotation)) // Rotate the icon.
            .offset(x: xOffset, y: yOffset)
            .onAppear {
                // Randomize the rotation and movement of the icon.
                withAnimation(.linear(duration: 2.5)) {
                    yOffset = 1000
                    xOffset += .random(in: -250...100)
                }
            }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ScoreTransitionScreen(reviewViewState: .constant(.correctMessage), scoreType: .correct)
}

#Preview {
    ScoreTransitionScreen(reviewViewState: .constant(.incorrectMessage), scoreType: .incorrect)
}
#endif
