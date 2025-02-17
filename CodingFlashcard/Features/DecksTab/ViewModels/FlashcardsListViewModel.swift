//
//  FlashcardsListViewModel.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import Foundation
import Combine

@MainActor
final class FlashcardsListViewModel: ObservableObject {
    @Published var flashcards: [Flashcard] = []
    @Published var isEndOfList: Bool = false
    
    // MARK: Propagated Properties from Search Bar Manager
    @Published var searchText: String = ""
    @Published var searchState: SearchState = .idle
    @Published var searchResults: [SearchResult] = []
    @Published var searchBarErrorToast: Toast?
    @Published var selectedDeckID: String? = nil
    @Published var selectedDeckIDData: (Theme, String) = (.blue, "Flashcards")
    
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
    
    // MARK: - Search bar methods
    private func search(searchText: String) async throws -> [SearchResult] {
        try await databaseManager.fetchSearchFlashcards(for: searchText)
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
    
    // MARK: - Flashcard data methods
    func fetchFlashcardListData(for deckID: String) async {
        do {
            let fetchedFlashcards = try await databaseManager.fetchFlashcards(forDeckID: deckID)
            self.flashcards = orderFlashcardsByUpdatedDate(flashcards: fetchedFlashcards)
        } catch {
            self.flashcards = []
        }
    }
    
    func deleteFlashcard(id: String) async throws {
        try await databaseManager.deleteFlashcard(by: id)
    }
    
    func fetchInitialFlashcards(selectedDeckID: String) async throws {
        isEndOfList = false
        if let deck = try await databaseManager.fetchDeck(for: selectedDeckID) {
            let flashcardIDs = deck.flashcardIDs
            let newFlashcards = try await databaseManager.fetchInitialFlashcards(forFlashcardIDs: flashcardIDs)
            if newFlashcards.count < 10 {
                isEndOfList = true
            }
            self.flashcards = newFlashcards
        } else {
            self.flashcards = []
        }
    }
    
    func fetchMoreFlashcards(selectedDeckID: String) async throws {
        if let deck = try await databaseManager.fetchDeck(for: selectedDeckID) {
            let flashcardIDs = deck.flashcardIDs
            if let lastFlashcard = flashcards.last {
                let newFlashcards = try await databaseManager.fetchMoreFlashcards(lastFlashcardID: lastFlashcard.id, forFlashcardIDs: flashcardIDs)
                if newFlashcards.count < 10 {
                    isEndOfList = true
                }
                self.flashcards.append(contentsOf: newFlashcards)
            } else {
                self.isEndOfList = true
            }
        } else {
            self.isEndOfList = true
        }
    }
}
