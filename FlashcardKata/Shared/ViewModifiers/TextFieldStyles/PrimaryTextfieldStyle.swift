//
//  PrimaryTextfieldStyle.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View modifier that applies a primary text field style.

import SwiftUI

struct PrimaryTextfieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.customAccent3)
            .clipDefaultShape()
    }
}

extension View {
    func primaryTextfieldStyle() -> some View {
        self.modifier(PrimaryTextfieldStyle())
    }
}
