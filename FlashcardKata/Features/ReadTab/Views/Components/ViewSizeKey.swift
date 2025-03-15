//
//  ViewSizeKey.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Passes the size of the view using GeometryReader.

import SwiftUI

struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct ViewGeometry: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ViewSizeKey.self, value: geometry.size)
        }
    }
}
