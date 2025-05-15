//
//  ClearProgressScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Displays a custom overlay progress view.

import SwiftUI

struct OverlayProgressScreen: View {
    @State private var showSpinner = false
    @State private var currentTask: Task<Void, Never>?
    let delay: TimeInterval = 0.5
    
    var body: some View {
        ZStack {
            Color.clear
            VStack {
                Spacer()
                if showSpinner {
                    LoadingIcon()
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
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

extension View {
    func applyOverlayProgressScreen(isViewDisabled: Binding<Bool>) -> some View {
        self
            .allowsHitTesting(!isViewDisabled.wrappedValue)
            .overlay {
                if isViewDisabled.wrappedValue {
                    OverlayProgressScreen()
                        .edgesIgnoringSafeArea(.all)
                        .transition(.identity)
                }
            }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ZStack {
        Color.blue.opacity(0.3)
        OverlayProgressScreen()
    }
}
#endif
