//
//  SearchBarViewModel.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This class manages the state of the search bar, including the search text,
//  search results, and the state of the search process.

import Foundation
import Combine

/// A class that manages the state of the search bar.
@MainActor
class SearchBarManager: ObservableObject {
    // MARK: - Properties
    @Published var searchText: String = ""
    @Published var searchResults: [SearchResult] = []
    @Published var searchState: SearchState = .idle
    @Published var errorToast: Toast?

    private var cancellables: Set<AnyCancellable> = []
    
    /// Sets up the search functonality by debouncing the search text input and triggering the search operation.
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

    /// Performs the search operation based on the provided search function.
    private func performSearch(search: (_ searchText: String) async throws -> [SearchResult]) async {
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
                setErrorMessage(for: error)
                reportError(error)
            }
        }
    }
    
    /// Sets the error toast message based on the error type.
    private func setErrorMessage(for error: Error) {
        if let appError = error as? AppError {
            errorToast = Toast(style: .warning, message: appError.message)
        } else {
            errorToast = Toast(style: .warning, message: AppError.systemError.message)
        }
    }

    func clearSearchText() {
        searchText = ""
        searchResults = []
        searchState = .idle
    }
}
