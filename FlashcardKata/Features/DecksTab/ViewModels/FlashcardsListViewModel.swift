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

/// A view model that manages the state and operations for a list of flashcards.
@MainActor
final class FlashcardsListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var flashcards: [Flashcard] = []
    @Published var isEndOfList: Bool = false // Indicates if the end of the flashcard list has been reached.
    @Published var selectedDeckID: String? // The ID of the currently selected deck.
    @Published var selectedDeckIDData: (Theme, String) = (.blue, "Flashcards")
    
    // MARK: Search Bar Properties
    @Published var searchText: String = ""
    @Published var searchState: SearchState = .idle
    @Published var searchResults: [SearchResult] = []
    @Published var searchBarErrorToast: Toast?
    
    // MARK: - Dependencies
    private var searchBarManager: SearchBarManager
    var databaseManager: DatabaseManagerProtocol
    private let fetchItemLimit: Int // The limit for fetching items per page in pagination.
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Pagination
    // Manages pagination for flashcards, allowing for loading initial and more items.
    // Lazy initialization to allow for dependency injection after the view model is created.
    private lazy var paginationManager: PaginationManager<Flashcard> = {
        let manager = PaginationManager<Flashcard>(
            pageLimit: fetchItemLimit,
            fetchInitial: {
                guard let deckID = self.selectedDeckID else { return [] }
                return await self.loadInitialFlashcardListData(selectedDeckID: deckID)
            },
            fetchMore: { lastID in
                guard let deckID = self.selectedDeckID else { return [] }
                return await self.loadMoreFlashcardListData(selectedDeckID: deckID, lastFlashcardID: lastID)
            }
        )
        setUpBindings(with: manager)
        return manager
    }()
    
    // MARK: - Initializer
    init(
        searchBarManager: SearchBarManager,
        databaseManager: DatabaseManagerProtocol,
        fetchItemLimit: Int = ContentConstants.fetchItemLimit
    ) {
        self.searchBarManager = searchBarManager
        self.databaseManager = databaseManager
        self.fetchItemLimit = fetchItemLimit

        // Sync search bar properties with the view model.
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

        // Sync search text between the view model and search bar manager.
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
    
    // MARK: - General Methods
    // Sets up bindings to sync PaginationManager state with view model properties.
    private func setUpBindings(with manager: PaginationManager<Flashcard>) {
        manager.$items
            .assign(to: &$flashcards)
        manager.$isEndOfList
            .assign(to: &$isEndOfList)
    }
    
    /// Resets the view model to its initial state, including search and pagination.
    func resetViewModel() {
        clearSearchText()
        paginationManager.reset()
    }
    
    /// Determines if the end of the flashcard list is reached based on the number of items fetched.
    private func checkIFEndOfList(_ fetchedCount: Int) {
        isEndOfList = fetchedCount < fetchItemLimit
    }

    // MARK: - Search methods
    /// Performs a search for flashcards based on the provided search text.
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
    /// Fetches flashcard data for the selected deck ID.
    func fetchFlashcardListData(for deckID: String) async {
        do {
            let fetchedFlashcards = try await databaseManager.fetchFlashcardsForDeckID(deckID: deckID)
            self.flashcards = orderFlashcardsByUpdatedDate(flashcards: fetchedFlashcards)
        } catch {
            self.flashcards = []
            reportError(error)
        }
    }

    func deleteFlashcard(id: String) async throws {
        try await databaseManager.deleteFlashcard(by: id)
    }
    
    /// Fetches the initial set of flashcards for pagination.
    func fetchInitialFlashcards() async {
        await paginationManager.loadInitialItems()
    }
    
    /// Fetches additional flashcards for pagination.
    func fetchMoreFlashcards() async {
        await paginationManager.loadMoreItems()
    }
    
    /// Loads initial flashcard list data for the selected deck ID, to be passed into Pagination Manager.
    private func loadInitialFlashcardListData(selectedDeckID: String) async -> [Flashcard] {
        do {
            guard let flashcardIDs = try await fetchFlashcardIDs(for: selectedDeckID) else {
                return []
            }
            return try await databaseManager.fetchInitialFlashcards(forFlashcardIDs: flashcardIDs)
        } catch {
            reportError(error)
            return []
        }
    }
    
    /// Loads more flashcard list data for the selected deck ID, to be passed into Pagination Manager.
    private func loadMoreFlashcardListData(selectedDeckID: String, lastFlashcardID: String) async -> [Flashcard] {
        do {
            // Fetch flashcard IDs for the selected deck.
            guard let flashcardIDs = try await fetchFlashcardIDs(for: selectedDeckID) else {
                return []
            }
            // Fetch more flashcards using the last fetched flashcard ID.
            return try await databaseManager.fetchMoreFlashcards(
                lastFlashcardID: lastFlashcardID,
                flashcardIDs: flashcardIDs
            )
        } catch {
            reportError(error)
            return []
        }
    }
    
    /// Fetches flashcard IDs for the selected deck ID.
    private func fetchFlashcardIDs(for deckID: String) async throws -> [String]? {
        guard let deck = try? await databaseManager.fetchDeck(for: deckID) else {
            reportError(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Deck not found"]))
            return nil
        }
        return deck.flashcardIDs
    }
}
