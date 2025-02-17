//
//  InputControlStyle.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct InputControlStyle: ViewModifier {
    let backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding(7.5)
            .background(backgroundColor.opacity(0.2))
            .background(.white)
            .clipDefaultShape()
    }
}

extension View {
    func applyInputControlStyle(backgroundColor: Color) -> some View {
        self.modifier(InputControlStyle(backgroundColor: backgroundColor))
    }
}
