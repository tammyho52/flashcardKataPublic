//
//  StandardSectionStyle.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct StandardSectionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(.white)
            .clipDefaultShape()
            .applySectionShadow()
            .padding()
    }
}

extension View {
    func standardSectionStyle() -> some View {
        self.modifier(StandardSectionStyle())
    }
}
