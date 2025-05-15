//
//  SearchState.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Defines the various states of a search process.

import Foundation

/// Represents the different states of a search process.
enum SearchState: String, Equatable {
    case idle // Initial state, no search has been initiated
    case loading // Search is in progress
    case noResults // No results were found for the search process
    case error // An error occurred during search process
    case resultsFound // Results were found for the search process
}

/// Conforms to `Identifiable` protocol.
extension SearchState: Identifiable{
    var id: String {
        switch self {
        case .idle: return "idle"
        case .loading: return "loading"
        case .noResults: return "no results"
        case .error: return "error"
        case .resultsFound: return "results"
        }
    }
}
