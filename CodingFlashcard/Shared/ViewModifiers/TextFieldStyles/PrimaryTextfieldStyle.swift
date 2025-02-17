//
//  PrimaryTextfieldStyle.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

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
