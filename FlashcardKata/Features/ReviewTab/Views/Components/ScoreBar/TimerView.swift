//
//  TimerView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view that displays the current remaining time for Timed review mode sessions.

import SwiftUI
import Combine

/// A view that displays a timer with remaining time for Timed review mode sessions.
struct TimerView: View {
    // MARK: - Properties
    @Binding var secondsRemaining: Int

    // MARK: - Body
    var body: some View {
        HStack {
            Image(systemName: "timer")
                .font(.title)
            Text("\(timeString(time: secondsRemaining))")
                .font(.customTitle2)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .fontWeight(.semibold)
    }

    // MARK: - Private Methods
    /// Converts seconds to a string formatted as MM:SS.
    private func timeString(time: Int) -> String {
        let minutes = time / 60 % 60
        let seconds = time % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ZStack {
        Color.gray
        TimerView(secondsRemaining: .constant(60))
    }
}
#endif
