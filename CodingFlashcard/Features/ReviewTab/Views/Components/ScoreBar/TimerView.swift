//
//  TimerView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI
import Combine

struct TimerView: View {
    @Binding var secondsRemaining: Int
    
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
    
    private func timeString(time: Int) -> String {
        let minutes = time / 60 % 60
        let seconds = time % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}

#if DEBUG
#Preview {
    ZStack {
        Color.gray
        TimerView(secondsRemaining: .constant(60))
    }
}
#endif
