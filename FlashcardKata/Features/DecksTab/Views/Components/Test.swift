//
//  Test.swift
//  CodingFlashcard
//
//  Created by Tammy Ho on 6/19/24.
//

import SwiftUI

struct TestDeck: Identifiable {
    let id = UUID()
    var parentDeckID: UUID?
//    var content: Content = Content()
    var name: String = ""
    var flashcardIDs: [UUID] = []
    var subDecks: [Deck] = []
}

struct Test: View {
    @State var deck: Deck = Deck()
    var body: some View {
        TextField("hellp", text: $deck.name)
        Text("\(deck.name)")
            .background(deck.name.isEmpty ? .gray : .blue)
    }
}

#Preview {
    Test()
}
