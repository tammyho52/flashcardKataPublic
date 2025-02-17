//
//  LargeProgressView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

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
