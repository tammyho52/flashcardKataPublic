//
//  ViewSizeKey.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A utility to pass the size of a view using GeometryReader and PreferenceKey.

import SwiftUI

/// A `PreferenceKey` implementation to store and pass the size of a view.
struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

/// A view that uses `GeometryReader` to capture and pass its size via `ViewSizeKey`.
struct ViewGeometry: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ViewSizeKey.self, value: geometry.size)
        }
    }
}
