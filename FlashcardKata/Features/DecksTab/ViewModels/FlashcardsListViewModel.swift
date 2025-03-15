//
//  FlashcardsListViewModel.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View model managing the list of flashcards, handling search functionality,
//  and interacting with the database to fetch, update, and delete flashcards.

import Foundation
import Combine

@MainActor
final class FlashcardsListViewModel: ObservableObject {
    @Published var flashcards: [Flashcard] = []
    @Published var isEndOfList: Bool = false
    @Published var searchText: String = ""
    @Published var searchState: SearchState = .idle
    @Published var searchResults: [SearchResult] = []
    @Published var searchBarErrorToast: Toast?
    @Published var selectedDeckID: String?
    @Published var selectedDeckIDData: (Theme, String) = (.blue, "Flashcards")

    private var searchBarManager: SearchBarManager
    var databaseManager: DatabaseManagerProtocol
    private var cancellables = Set<AnyCancellable>()

    init(searchBarManager: SearchBarManager, databaseManager: DatabaseManagerProtocol) {
        self.searchBarManager = searchBarManager
        self.databaseManager = databaseManager

        // Sync search bar properties with view model.
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

        // Sync search text between ViewModel and search bar manager.
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

    // MARK: - Search methods
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

    // MARK: - Flashcard Data Methods
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
                let newFlashcards = try await databaseManager.fetchMoreFlashcards(
                    lastFlashcardID: lastFlashcard.id,
                    flashcardIDs: flashcardIDs
                )
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
