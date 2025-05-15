//
//  LargeProgressView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Displays a custom full screen progress view.

import SwiftUI

struct FullScreenProgressScreen: View {
    @State private var showSpinner = false
    @State private var currentTask: Task<Void, Never>?
    let delay: TimeInterval = 0.5
    
    var body: some View {
        ZStack {
            Color.customAccent.opacity(0.1)
            if showSpinner {
                LoadingIcon()
            }
        }
        .transition(.identity)
        .onAppear {
            currentTask = Task {
                try? await Task.sleep(for: .seconds(delay))
                withAnimation {
                    showSpinner = true
                }
            }
        }
        .onDisappear {
            currentTask?.cancel()
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    FullScreenProgressScreen()
}
#endif
