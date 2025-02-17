//
//  DecksListViewModel.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI
import Combine

@MainActor
final class DecksListViewModel: ObservableObject {
    @Published var decks: [Deck] = []
    @Published var subdecksByDeckID: [String: [Deck]] = [:]
    @Published var isEndOfList: Bool = false
    
    // MARK: Propagated Properties from Search Bar Manager
    @Published var searchText: String = ""
    @Published var searchState: SearchState = .idle
    @Published var searchResults: [SearchResult] = []
    @Published var searchBarErrorToast: Toast?
    @Published var dataErrorToast: Toast?
    
    private var searchBarManager: SearchBarManager
    var databaseManager: DatabaseManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(searchBarManager: SearchBarManager, databaseManager: DatabaseManagerProtocol) {
        self.searchBarManager = searchBarManager
        self.databaseManager = databaseManager
        
        searchBarManager.$searchState
            .assign(to: &$searchState)
        searchBarManager.$searchResults
            .assign(to: &$searchResults)
        searchBarManager.$errorToast
            .assign(to: &$searchBarErrorToast)
        searchBarManager.$searchText
            .removeDuplicates()
            .sink { [weak self] newValue in
                guard let self else { return }
                if self.searchText != newValue {
                    self.searchText = newValue
                }
            }
            .store(in: &cancellables)
        
        $searchText
            .removeDuplicates()
            .sink { [weak self] newValue in
                guard let self else { return }
                if self.searchBarManager.searchText != newValue {
                    self.searchBarManager.searchText = newValue
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Guest Methods
    func isGuestUser() -> Bool {
        databaseManager.isGuestUser()
    }
    
    func navigateToSignInWithoutAccount() {
        databaseManager.navigateToSignInWithoutAccount()
    }
    
    // MARK: - Search bar methods
    private func search(searchText: String) async throws -> [SearchResult] {
        try await databaseManager.fetchSearchDecks(for: searchText)
    }
    
    func clearSearchText() {
        searchBarManager.clearSearchText()
    }
    
    func setUpSearch() async {
        searchBarManager.setupSearch(search: search)
    }
    
    func performSearch() async {
        await searchBarManager.performSearch(search: search)
    }
    
    // MARK: - Deck data methods
    func fetchDeckListData() async {
        do {
            let decks = try await databaseManager.fetchAllParentDecks(deckCountLimit: 30)
            self.decks = decks
            if !decks.isEmpty {
                let newSubdecks = try await databaseManager.fetchAllSubDecks(deckCountLimit: 30)
                if !newSubdecks.isEmpty {
                    self.subdecksByDeckID  = newSubdecks.reduce(into: [String: [Deck]]()) { subdecksByDeckID, subdeck in
                        if let parentDeckID = subdeck.parentDeckID {
                            subdecksByDeckID[parentDeckID, default: []].append(subdeck)
                        }
                    }
                }
            }
        } catch {
            self.decks = []
            self.subdecksByDeckID = [:]
        }
    }
    
    func fetchInitialDeckListData() async throws {
        isEndOfList = false
        let decks = try await databaseManager.fetchInitialParentDecks()
        guard !decks.isEmpty else {
            isEndOfList = true
            return
        }
        self.decks = decks
        try await setSubdecksByDeckID(for: decks)
    }
    
    private func setSubdecksByDeckID(for decks: [Deck]) async throws {
        for deck in decks {
            try Task.checkCancellation()
            let subdecks = try await databaseManager.fetchSubdecks(for: deck.subdeckIDs)
            subdecksByDeckID[deck.id] = subdecks
        }
    }
    
    func fetchMoreDeckListData() async throws {
        if let lastDeck = decks.last {
            let newDecks = try await databaseManager.fetchMoreParentDecks(lastDeckID: lastDeck.id)
            guard !newDecks.isEmpty else {
                isEndOfList = true
                return
            }
            if newDecks.count < 10 {
                isEndOfList = true
            }
            decks.append(contentsOf: newDecks)
            try await setSubdecksByDeckID(for: decks)
        }
    }
    
    func deleteDeckAndAssociatedData(id: String) async throws {
        try await databaseManager.deleteDeckAndAssociatedData(id: id)
    }
    
    func fetchDeck(id: String) async throws -> Deck? {
        return try await databaseManager.fetchDeck(for: id)
    }
}
