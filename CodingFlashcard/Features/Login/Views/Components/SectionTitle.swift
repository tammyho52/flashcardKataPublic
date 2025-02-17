//
//  SignInTitle.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct SectionTitle: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.customTitle)
            .fontWeight(.semibold)
            .foregroundStyle(Color.customPrimary)
    }
}

#if DEBUG
#Preview {
    SectionTitle(text: "Sign Up")
}
#endif
