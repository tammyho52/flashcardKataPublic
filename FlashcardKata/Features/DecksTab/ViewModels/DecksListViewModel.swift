//
//  DecksListViewModel.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view model responsible for managing the list of decks and subdecks. It handles search functionality,
//  pagination, and interactions with the database to fetch, update, and delete decks. This view model
//  provides a structured interface for the view layer to manage deck-related operations.

import SwiftUI
import Combine

/// A view model for managing the state and operations of decks and subdecks.
@MainActor
final class DecksListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var deckWithSubdecks: [DeckWithSubdecks] = []
    @Published var isEndOfList: Bool = false

    // MARK: - Search Bar Properties
    @Published var searchText: String = ""
    @Published var searchState: SearchState = .idle
    @Published var searchResults: [SearchResult] = []
    @Published var searchBarErrorToast: Toast?

    // MARK: - Dependencies
    private var searchBarManager: SearchBarManager
    var databaseManager: DatabaseManagerProtocol
    private let fetchItemLimit: Int
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var allDecks: [Deck] {
        return deckWithSubdecks.flatMap {
            [$0.parentDeck] + $0.subdecks
        }
    }
    
    // MARK: - Pagination
    // Manages pagination for decks with subdecks, allowing for loading initial and more items.
    // Lazy initialization to allow for dependency injection after the view model is created.
    private lazy var paginationManager: PaginationManager<DeckWithSubdecks> = {
        let manager = PaginationManager<DeckWithSubdecks>(
            pageLimit: fetchItemLimit,
            fetchInitial: { [weak self] in
                return await self?.loadInitialDeckWithSubdecksListData() ?? []
            },
            fetchMore: { [weak self] lastID in
                return await self?.loadMoreDeckWithSubdecksListData(lastFlashcardID: lastID) ?? []
            }
        )
        setUpBindings(with: manager)
        return manager
    }()
    
    // MARK: - Initialization
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

        // Sync search text between view model and search bar manager.
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
    /// Sets up bindings to sync PaginationManager state with view model properties.
    private func setUpBindings(with manager: PaginationManager<DeckWithSubdecks>) {
        manager.$items
            .assign(to: &$deckWithSubdecks)
        manager.$isEndOfList
            .assign(to: &$isEndOfList)
    }
    
    /// Resets the view model to its initial state, including search and pagination.
    func resetViewModel() {
        clearSearchText()
        paginationManager.reset()
    }

    // MARK: - Guest User Methods
    func isGuestUser() -> Bool {
        databaseManager.isGuestUser()
    }

    func navigateToSignInWithoutAccount() {
        databaseManager.navigateToSignInWithoutAccount()
    }

    // MARK: - Search Bar Methods
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

    // MARK: - Deck Data Methods
    func fetchDeckListData(deckCountLimit: Int? = nil) async {
        do {
            let decks = try await databaseManager.fetchAllParentDecks(deckCountLimit: deckCountLimit)
            let subdecksByDeckID = try await getSubdecksByDeckID(for: decks)
            self.deckWithSubdecks = createDecksWithSubdecks(
                decks: decks,
                subdecksByID: subdecksByDeckID
            )
        } catch {
            self.deckWithSubdecks = []
            reportError(error)
        }
    }
    
    /// Fetches the initial set of decks with subdecks for pagination.
    func fetchInitialDecksWithSubdecks() async {
        await paginationManager.loadInitialItems()
    }
    
    /// Fetches more decks with subdecks for pagination.
    func fetchMoreDecksWithSubdecks() async {
        await paginationManager.loadMoreItems()
    }
    
    /// Fetches the initial set of decks with subdecks, used in pagination manager.
    private func loadInitialDeckWithSubdecksListData() async -> [DeckWithSubdecks] {
        do {
            let decks = try await databaseManager.fetchInitialParentDecks()
            let subdecksByID: [String: [Deck]] = try await getSubdecksByDeckID(for: decks)
            
            return createDecksWithSubdecks(decks: decks, subdecksByID: subdecksByID)
        } catch {
            reportError(error)
            return []
        }
    }
    
    /// Fetches more decks with subdecks, used in pagination manager.
    private func loadMoreDeckWithSubdecksListData(lastFlashcardID: String) async -> [DeckWithSubdecks] {
        do {
            let decks = try await databaseManager.fetchMoreParentDecks(lastDeckID: lastFlashcardID)
            let subdecksByID: [String: [Deck]] = try await getSubdecksByDeckID(for: decks)
            
            return createDecksWithSubdecks(decks: decks, subdecksByID: subdecksByID)
        } catch {
            reportError(error)
            return []
        }
    }
    
    /// Creates a list of decks with their associated subdecks.
    private func createDecksWithSubdecks(decks: [Deck], subdecksByID: [String: [Deck]]) -> [DeckWithSubdecks] {
        return decks.compactMap { deck in
            guard let subdecks = subdecksByID[deck.id] else { return nil }
            return DeckWithSubdecks(parentDeck: deck, subdecks: subdecks)
        }
    }
    
    /// Fetches subdecks for a given list of decks.
    private func getSubdecksByDeckID(for decks: [Deck]) async throws -> [String: [Deck]] {
        var result: [String: [Deck]] = [:]
        
        try await withThrowingTaskGroup(of: (String, [Deck])?.self) { group in
            for deck in decks {
                try Task.checkCancellation()
                group.addTask { [weak self] in
                    guard let self else { return nil }
                    let subdecks = try await self.databaseManager.fetchSubdecks(for: deck.subdeckIDs)
                    return (deck.id, subdecks)
                }
            }
            
            for try await pair in group {
                if let (deckID, subdecks) = pair {
                    result[deckID] = subdecks
                }
            }
        }
        return result
    }
    
    func deleteDeckAndAssociatedData(id: String) async throws {
        try await databaseManager.deleteDeckAndAssociatedData(id: id)
    }

    func fetchDeck(id: String) async throws -> Deck? {
        return try await databaseManager.fetchDeck(for: id)
    }
}
