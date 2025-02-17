//
//  ProgressViewLoading.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct ProgressViewLoading: View {
    var body: some View {
        HStack(spacing: 10) {
            Text("Loading..")
            ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: 20, alignment: .center)
        .padding(.vertical, 10)
    }
}
