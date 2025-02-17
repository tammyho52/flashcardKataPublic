//
//  ApplySearchable.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct ApplySearchable: ViewModifier {
    @Binding var searchText: String
    
    var showSearchable: Bool
    let prompt: String
    
    func body(content: Content) -> some View {
        if showSearchable {
            content
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: prompt)
        } else {
            content
        }
    }
}

extension View {
    func applySearchable(searchText: Binding<String>, showSearchable: Bool, prompt: String) -> some View {
        self.modifier(
            ApplySearchable(searchText: searchText, showSearchable: showSearchable, prompt: prompt)
        )
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        Text("Hello World")
            .applySearchable(searchText: .constant(""), showSearchable: true, prompt: "Search")
    }
}

#Preview {
    NavigationStack {
        Text("Hello World")
            .applySearchable(searchText: .constant(""), showSearchable: false, prompt: "Search")
    }
}
#endif
