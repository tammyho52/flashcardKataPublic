//
//  AppBackgroundView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

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

#if DEBUG
#Preview {
    BackgroundImage(image: ContentConstants.Images.appBackgroundImage)
}
#endif
