//
//  ErrorView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct ErrorView: View {
    @State var isRetrying: Bool = false
    
    let error: AppError
    let dismissAction: (() -> Void)
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack {
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
                        HStack {
                            Image(systemName: "arrow.trianglehead.clockwise")
                            Text("Retry")
                        }
                        .padding()
                        .foregroundStyle(.white)
                        .background(Color.blue)
                        .clipDefaultShape()
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    ErrorView(error: .networkError, dismissAction: {}, retryAction: {})
}
#endif
