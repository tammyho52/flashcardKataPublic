//
//  ListSectionStyle.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct ListSectionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .fontWeight(.semibold)
    }
}

extension View {
    func applyListSectionStyle() -> some View {
        self
            .modifier(ListSectionStyle())
    }
}
