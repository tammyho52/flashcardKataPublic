//
//  ProgressOverlayModifier.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct ProgressOverlayModifier2: ViewModifier {
    @Binding var isShowing: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isShowing)
                .blur(radius: isShowing ? 2 : 0)
            
            if isShowing {
                FullScreenProgressScreen()
            }
        }
    }
}

#if DEBUG
#Preview {
    Text("Hello")
        .modifier(ProgressOverlayModifier2(isShowing: .constant(true)))
}
#endif
