//
//  StreakCountView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct StreakCountView: View {
    @Binding var incorrectScore: Int
    @Binding var correctScore: Int
    
    let currentStreak: Int
    let highStreak: Int
    
    var body: some View {
        VStack {
            Text("Current: \(currentStreak)")
            Text("Streak: \(highStreak)")
        }
        .frame(maxWidth: .infinity)
        .font(.title3)
        .foregroundStyle(.white)
        .fontWeight(.semibold)
    }
}

#if DEBUG
#Preview {
    ZStack {
        Color.gray
        StreakCountView(incorrectScore: .constant(0), correctScore: .constant(0), currentStreak: 0, highStreak: 0)
    }
}
#endif
