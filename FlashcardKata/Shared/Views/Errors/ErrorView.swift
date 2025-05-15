//
//  ErrorView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Displays a customizable toast message to the user with dismiss and retry actions.

import SwiftUI

struct ErrorView: View {
    @State private var isRetrying: Bool = false

    let error: AppError
    let dismissAction: (() -> Void)
    let retryAction: (() -> Void)?

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ToastView(
                    style: .error,
                    message: error.message,
                    onCancelTapped: dismissAction
                )

                if let retryAction {
                    if isRetrying {
                        ProgressView()
                            .padding()
                    } else {
                        Button(action: retryAction) {
                            Image(systemName: "arrow.trianglehead.clockwise")
                                .padding()
                                .foregroundStyle(.white)
                                .background(Color.blue)
                                .clipDefaultShape()
                        }
                        .padding(5)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ErrorView(error: .networkError, dismissAction: {}, retryAction: {})
}
#endif
