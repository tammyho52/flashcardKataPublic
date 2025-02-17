//
//  GeometryReaderModifier.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct GeometryReaderModifier: ViewModifier {
    let onGeometryChange: (CGSize, CGRect) -> Void
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            onGeometryChange(geometry.size, geometry.frame(in: .global))
                        }
                        .onChange(of: geometry.size) {
                            onGeometryChange(geometry.size, geometry.frame(in: .global))
                        }
                }
            )
    }
}

extension View {
    func observeGeometry(onChange: @escaping (CGSize, CGRect) -> Void) -> some View {
        self.modifier(GeometryReaderModifier(onGeometryChange: onChange))
    }
}
