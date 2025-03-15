//
//  ClearProgressScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Displays a custom overlay progress view.

import SwiftUI

struct OverlayProgressScreen: View {
    var body: some View {
        ZStack {
            Color.clear
            VStack {
                Spacer()
                LoadingIcon()
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                Spacer()
            }
            .edgesIgnoringSafeArea(.bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .disabled(true)
    }
}

extension View {
    func applyOverlayProgressScreen(isViewDisabled: Binding<Bool>) -> some View {
        self.overlay {
            if isViewDisabled.wrappedValue {
                OverlayProgressScreen()
                    .transition(.identity)
            }
        }
    }
}

#if DEBUG
#Preview {
    ZStack {
        Color.blue.opacity(0.3)
        OverlayProgressScreen()
    }
}
#endif
