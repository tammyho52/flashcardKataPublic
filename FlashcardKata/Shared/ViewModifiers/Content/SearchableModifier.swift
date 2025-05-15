//
//  ApplySearchable.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View modifier to add a search bar to the view.

import SwiftUI

struct SearchableModifier: ViewModifier {
    @Binding var searchText: String

    let prompt: String

    func body(content: Content) -> some View {
        content
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: prompt)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
    }
}

extension View {
    func applySearchable(searchText: Binding<String>, prompt: String) -> some View {
        self.modifier(
            SearchableModifier(searchText: searchText, prompt: prompt)
        )
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    NavigationStack {
        Text("Hello World")
            .applySearchable(searchText: .constant(""), prompt: "Search")
    }
}

#Preview {
    NavigationStack {
        Text("Hello World")
            .applySearchable(searchText: .constant(""), prompt: "Search")
    }
}
#endif
