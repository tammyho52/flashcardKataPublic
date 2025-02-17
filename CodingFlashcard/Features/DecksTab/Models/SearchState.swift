//
//  SearchState.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import Foundation

enum SearchState: String {
    case idle
    case loading
    case noResults
    case error
    case resultsFound
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
