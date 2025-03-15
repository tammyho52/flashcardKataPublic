//
//  SearchState.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Represents the different states of a search process.

import Foundation

enum SearchState: String {
    case idle // No search initiated
    case loading // Search is in progress
    case noResults // Search completed with no results
    case error // An error occurred during search
    case resultsFound // Search completed with results
}

extension SearchState: Identifiable, Equatable {
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
