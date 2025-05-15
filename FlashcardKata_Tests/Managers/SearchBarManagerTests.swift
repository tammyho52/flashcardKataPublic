//
//  SearchBarManagerTests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import Testing
import Combine
import Foundation

@MainActor
struct SearchBarManagerTests {
    
    private func sleepTaskForSearchDebouncing() async throws {
        try await Task.sleep(for: .seconds(2))
    }
    
    @Test func testInitialState() async throws {
        let searchBarManager = SearchBarManager()
        #expect(searchBarManager.searchText == "")
        #expect(searchBarManager.searchResults.isEmpty)
        #expect(searchBarManager.searchState == .idle)
        #expect(searchBarManager.errorToast == nil)
    }
    
    @Test func testPerformSearch_WithResults() async throws {
        let mockSearch: (String) async throws -> [SearchResult] = { _ in
            return [SearchResult.sampleDeck]
        }
        let searchBarManager = SearchBarManager()
        searchBarManager.setupSearch(search: mockSearch)
        let expectedSearchText = "test"
        searchBarManager.searchText = expectedSearchText
        
        try await sleepTaskForSearchDebouncing()
        
        #expect(searchBarManager.searchState == .resultsFound)
        #expect(searchBarManager.searchResults.count == 1)
        #expect(searchBarManager.searchResults.first?.id == SearchResult.sampleDeck.id)
        #expect(searchBarManager.searchText == expectedSearchText)
    }
    
    @Test func testPerformSearch_NoResults() async throws {
        let mockSearch: (String) async throws -> [SearchResult] = { _ in
            return []
        }
        let searchBarManager = SearchBarManager()
        searchBarManager.setupSearch(search: mockSearch)
        let expectedSearchText = "test"
        searchBarManager.searchText = expectedSearchText
        
        try await sleepTaskForSearchDebouncing()
        
        #expect(searchBarManager.searchState == .noResults)
        #expect(searchBarManager.searchResults.isEmpty)
        #expect(searchBarManager.searchText == expectedSearchText)
    }
    
    @Test func testPerformSearch_Error() async throws {
        let mockSearch: (String) async throws -> [SearchResult] = { _ in
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        let searchBarManager = SearchBarManager()
        searchBarManager.setupSearch(search: mockSearch)
        let expectedSearchText = "test"
        searchBarManager.searchText = expectedSearchText
        
        try await sleepTaskForSearchDebouncing()
        
        #expect(searchBarManager.searchState == .error)
        #expect(searchBarManager.searchResults.isEmpty)
        #expect(searchBarManager.errorToast != nil)
        #expect(searchBarManager.searchText == expectedSearchText)
    }
    
    @Test func testEmptySearchTextAfterPreviousSearch() async throws {
        let mockSearch: (String) async throws -> [SearchResult] = { _ in
            return [SearchResult.sampleDeck]
        }
        let searchBarManager = SearchBarManager()
        searchBarManager.setupSearch(search: mockSearch)
        searchBarManager.searchText = "test"
        
        try await sleepTaskForSearchDebouncing()
        
        #expect(searchBarManager.searchState == .resultsFound)
        #expect(searchBarManager.searchResults.count == 1)
        
        searchBarManager.searchText = ""
        
        try await sleepTaskForSearchDebouncing()
        
        #expect(searchBarManager.searchState == .idle)
        #expect(searchBarManager.searchResults.isEmpty)
    }
    
    @Test func testRapidSearchTextChanges() async throws {
        let mockSearch: (String) async throws -> [SearchResult] = { _ in
            return [SearchResult.sampleDeck]
        }
        let searchBarManager = SearchBarManager()
        searchBarManager.setupSearch(search: mockSearch)
        
        var expectedSearchText: String = ""
        
        // Simulate rapid typing by quickly changing the search text
        for character in "test" {
            expectedSearchText.append(String(character))
            searchBarManager.searchText = expectedSearchText
            #expect(searchBarManager.searchResults.isEmpty)
            #expect(searchBarManager.searchState == .idle)
        }
        
        // Wait for the debounce period to pass
        try await sleepTaskForSearchDebouncing()
        
        // Assert that the search was performed for the final text
        #expect(searchBarManager.searchState == .resultsFound)
        #expect(searchBarManager.searchResults.count == 1)
        #expect(searchBarManager.searchResults.first?.id == SearchResult.sampleDeck.id)
    }
    
    @Test func testClearSearchText() async throws {
        let searchBarManager = SearchBarManager()
        let expectedSearchText = "test"
        searchBarManager.searchText = expectedSearchText
        searchBarManager.searchResults = [SearchResult.sampleDeck]
        searchBarManager.searchState = .loading
        
        #expect(searchBarManager.searchText == expectedSearchText)
        #expect(searchBarManager.searchResults.count == 1)
        #expect(searchBarManager.searchState == .loading)
        
        searchBarManager.clearSearchText()
        
        #expect(searchBarManager.searchText == "")
        #expect(searchBarManager.searchResults.isEmpty)
        #expect(searchBarManager.searchState == .idle)
    }
}
