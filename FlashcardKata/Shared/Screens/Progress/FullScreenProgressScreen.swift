//
//  LargeProgressView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Displays a custom full screen progress view.

import SwiftUI

struct FullScreenProgressScreen: View {
    var body: some View {
        ZStack {
            Color.customAccent.opacity(0.1)
            LoadingIcon()
        }
        .transition(.identity)
        .edgesIgnoringSafeArea(.bottom)
    }
}

#if DEBUG
#Preview {
    FullScreenProgressScreen()
}
#endif
