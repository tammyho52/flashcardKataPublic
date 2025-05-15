//
//  ListSectionStyle.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View modifier for List Section Header.

import SwiftUI

struct ListSectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .fontWeight(.semibold)
    }
}

extension View {
    func applyListSectionStyle() -> some View {
        self
            .modifier(ListSectionHeaderStyle())
    }
}
