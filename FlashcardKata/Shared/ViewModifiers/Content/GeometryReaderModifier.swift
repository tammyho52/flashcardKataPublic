//
//  GeometryReaderModifier.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View Modifer that uses `GeometryReader` to capture screen size and frame.

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
