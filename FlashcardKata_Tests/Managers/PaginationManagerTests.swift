//
//  PaginationManagerTests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import Testing

@MainActor
struct PaginationManagerTests {
    
    let pageLimit = 10
    
    private func createPaginationManager(items: [MockItem]) -> PaginationManager<MockItem> {
        return PaginationManager<MockItem>(
            pageLimit: pageLimit,
            fetchInitial: {
                return Array(items.prefix(10))
            },
            fetchMore: { lastID in
                if let lastIndex = items.firstIndex(where: { $0.id == lastID }) {
                    let nextIndex = items.index(after: lastIndex)
                    let nextItems = Array(items[nextIndex...])
                    return Array(nextItems.prefix(10))
                } else {
                    return []
                }
            }
        )
    }

    @Test func testInitialState_greaterThanPageLimit() async throws {
        let items = MockItem.createItems(count: 20)
        let manager = createPaginationManager(items: items)
        await manager.loadInitialItems()
        #expect(manager.items.count == 10)
        #expect(manager.isEndOfList == false)
        #expect(manager.items.last?.id == items[9].id)
    }
    
    @Test func testInitialState_lessThanPageLimit() async throws {
        let items = MockItem.createItems(count: 5)
        let manager = createPaginationManager(items: items)
        await manager.loadInitialItems()
        #expect(manager.items.count == 5)
        #expect(manager.isEndOfList == true)
        #expect(manager.items.last?.id == items.last?.id)
    }
    
    @Test func testLoadMoreItems() async throws {
        let items = MockItem.createItems(count: 28)
        let manager = createPaginationManager(items: items)
        await manager.loadInitialItems()
        #expect(manager.items.count == 10)
        #expect(manager.items.last?.id == items[9].id)
        
        // Load more items - not end of list
        await manager.loadMoreItems()
        #expect(manager.items.count == 20)
        #expect(manager.isEndOfList == false)
        #expect(manager.items.last?.id == items[19].id)
        
        // Load more items - end of list
        await manager.loadMoreItems()
        #expect(manager.items.count == 28)
        #expect(manager.isEndOfList == true)
        #expect(manager.items.last?.id == items.last?.id)
    }
    
    @Test func testReset() async throws {
        let items = MockItem.createItems(count: 20)
        let manager = createPaginationManager(items: items)
        await manager.loadInitialItems()
        #expect(manager.items.count == 10)
        
        // Reset the manager
        manager.reset()
        #expect(manager.items.count == 0)
        #expect(manager.isEndOfList == false)
    }
}
