//
//  CustomProgressView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct CustomProgressView: View {
    var body: some View {
        ProgressView()
            .controlSize(.large)
            .padding()
            .background(Color.customAccent3)
            .clipDefaultShape()
    }
}

#if DEBUG
#Preview {
    CustomProgressView()
}
#endif
