//
//  AppBackgroundView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View that sets a full screen background image.

import SwiftUI

struct BackgroundImage: View {
    let image: String

    var body: some View {
        Color.clear
            .overlay {
                Image(decorative: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.8)
                    .frame(width: UIScreen.main.bounds.width)
            }
            .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    BackgroundImage(image: ContentConstants.Images.appBackgroundImage)
}
#endif
