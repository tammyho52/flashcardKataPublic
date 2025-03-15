//
//  SearchBarViewModel.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Class that manages the state of the search bar, including the search text, search results,
//  and the state of the search process.

import Foundation
import Combine

@MainActor
class SearchBarManager: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [SearchResult] = []
    @Published var searchState: SearchState = .idle
    @Published var searchResultType: SearchResultType = .deck
    @Published var error: Error?
    @Published var errorToast: Toast?

    private var cancellables: Set<AnyCancellable> = []

    init() {
    }

    func setupSearch(search: @escaping (String) async throws -> [SearchResult]) {
        $searchText
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self else { return }
                Task {
                    await self.performSearch(search: search)
                }
            }
            .store(in: &cancellables)
    }

    func performSearch(search: (_ searchText: String) async throws -> [SearchResult]) async {
        if searchText.isEmpty {
            searchResults = []
            searchState = .idle
        } else {
            do {
                searchState = .loading
                searchResults = try await search(searchText)
                if searchResults.isEmpty {
                    searchState = .noResults
                } else {
                    searchState = .resultsFound
                }
            } catch {
                searchState = .error
                setErrorToast()
            }
        }
    }

    func clearSearchText() {
        searchText = ""
        searchState = .idle
    }

    private func setErrorToast() {
        errorToast = Toast(style: .error, message: AppError.networkError.message)
    }

    func reset(searchResultType: SearchResultType = .deck) {
        searchText = ""
        searchResults = []
        searchState = .idle
        self.searchResultType = searchResultType
        error = nil
    }
}
