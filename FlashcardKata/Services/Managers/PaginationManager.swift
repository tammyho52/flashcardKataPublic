//
//  PaginationManager.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
// This class provides a generic solution for managing data via pagination.

import Foundation

/// A generic manager for handling paginated data.
@MainActor
final class PaginationManager<T: Identifiable> {
    // MARK: - Properties
    @Published var items: [T] = []
    @Published var isEndOfList: Bool = false
    
    private var lastItemID: T.ID? = nil
    private let fetchInitial: () async -> [T]
    private let fetchMore: (_ afterID: T.ID) async -> [T]
    private let pageLimit: Int
    
    // MARK: - Initializer
    init(
        pageLimit: Int = 10,
        fetchInitial: @escaping () async -> [T],
        fetchMore: @escaping (_ afterID: T.ID) async -> [T]
    ) {
        self.pageLimit = pageLimit
        self.fetchInitial = fetchInitial
        self.fetchMore = fetchMore
    }
    
    /// Loads the initial items and checks if the end of the list has been reached.
    func loadInitialItems() async {
        let result = await fetchInitial()
        self.lastItemID = result.last?.id
        checkIsEndOfList(resultCount: result.count)
        items = result
    }
    
    /// Loads more items if the end of the list has not been reached and checks if the end of the list has been reached.
    func loadMoreItems() async {
        guard !isEndOfList, let lastItemID else { return }
        let result = await fetchMore(lastItemID)
        let newItems = items + result
        self.lastItemID = newItems.last?.id
        checkIsEndOfList(resultCount: result.count)
        items = newItems
    }
    
    /// Resets the pagination manager to its initial state.
    func reset() {
        items.removeAll()
        lastItemID = nil
        isEndOfList = false
    }
    
    /// Checks if the end of the list has been reached based on the result count.
    private func checkIsEndOfList(resultCount: Int) {
        isEndOfList = resultCount < pageLimit
    }
}
