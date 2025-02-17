//
//  SettingsListRowViewModifier.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct CapsuleRowBackground: View {
    var body: some View {
        Capsule()
            .strokeBorder(.gray)
            .padding(2.5)
            .background(.white.gradient)
            .clipShape(Capsule())
    }
}

#if DEBUG
#Preview {
    CapsuleRowBackground()
}
#endif
