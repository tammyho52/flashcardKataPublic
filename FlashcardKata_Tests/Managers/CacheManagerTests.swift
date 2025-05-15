//
//  CacheManagerTests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import Testing
@testable import FlashcardKata

@MainActor
struct CacheManagerTests {
    
    private func sleepTask() async throws {
        try await Task.sleep(for: .seconds(2))
    }
    
    @Test func testInitialState() async throws {
        let cacheManager = CacheManager<MockItem>()
        #expect(cacheManager.cacheCount == 0)
        #expect(cacheManager.lastDocumentID == nil)
        #expect(await cacheManager.retrieveItems().isEmpty)
    }
    
    @Test func testStoreInitialData_WithinLimit() async throws {
        let cacheManager = CacheManager<MockItem>()
        let items = MockItem.createItems(count: 10)
        await cacheManager.storeInitialData(items: items)
        
        #expect(cacheManager.cacheCount == 10)
        #expect(cacheManager.lastDocumentID == items.last?.id)
        #expect(await cacheManager.retrieveItems() == items)
    }
    
    @Test func testStoreInitialData_ExceedsLimit() async throws {
        let cacheManager = CacheManager<MockItem>()
        let cacheLimit = 30
        cacheManager.cacheLimit = cacheLimit
        
        let items = MockItem.createItems(count: 40)
        await cacheManager.storeInitialData(items: items)
        
        #expect(cacheManager.cacheCount == cacheLimit)
        #expect(cacheManager.lastDocumentID == items[29].id)
        #expect(await cacheManager.retrieveItems() == Array(items.prefix(30)))
    }
    
    @Test func testStoreNewItems_WithinLimit() async throws {
        let cacheManager = CacheManager<MockItem>()
        let cacheLimit = 30
        cacheManager.cacheLimit = cacheLimit
    
        let initialItems = MockItem.createItems(count: 20)
        await cacheManager.storeInitialData(items: initialItems)
        
        let newItems = MockItem.createItems(count: 5)
        await cacheManager.storeNewItems(newItems: newItems)
        
        try await sleepTask()
        #expect(cacheManager.cacheCount == 25)
        #expect(cacheManager.lastDocumentID == initialItems.last?.id)
        #expect(await cacheManager.retrieveItems() == newItems + initialItems)
    }
    
    @Test func testStoreNewItems_ExceedsLimit() async throws {
        let cacheManager = CacheManager<MockItem>()
        cacheManager.cacheLimit = 10
        let initialItems = MockItem.createItems(count: 5)
        await cacheManager.storeInitialData(items: initialItems)
        
        let newItems = MockItem.createItems(count: 10)
        await cacheManager.storeNewItems(newItems: newItems)
        
        try await sleepTask()
        #expect(cacheManager.cacheCount == 10)
        #expect(cacheManager.lastDocumentID == newItems[9].id)
        #expect(await cacheManager.retrieveItems() == newItems)
    }
    
    @Test func testStoreOldItems_WithinLimit() async throws {
        let cacheManager = CacheManager<MockItem>()
        let initialItems = MockItem.createItems(count: 5)
        await cacheManager.storeInitialData(items: initialItems)
        
        let oldItems = MockItem.createItems(count: 10)
        await cacheManager.storeOldItems(oldItems: oldItems)
        
        try await sleepTask()
        #expect(cacheManager.cacheCount == 15)
        #expect(cacheManager.lastDocumentID == oldItems[9].id)
        #expect(await cacheManager.retrieveItems() == initialItems + oldItems)
    }
    
    @Test func testStoreOldItems_ExceedsLimit() async throws {
        let cacheManager = CacheManager<MockItem>()
        cacheManager.cacheLimit = 10
        let initialItems = MockItem.createItems(count: 5)
        await cacheManager.storeInitialData(items: initialItems)
        
        let oldItems = MockItem.createItems(count: 10)
        await cacheManager.storeOldItems(oldItems: oldItems)
        
        try await sleepTask()
        
        let remainingItems = Array(oldItems.prefix(5))
        #expect(cacheManager.cacheCount == 10)
        #expect(cacheManager.lastDocumentID == remainingItems.last?.id)
        #expect(await cacheManager.retrieveItems() == initialItems + remainingItems)
    }
    
    @Test func testDeleteItems() async throws {
        let cacheManager = CacheManager<MockItem>()
        let items = MockItem.createItems(count: 10)
        await cacheManager.storeInitialData(items: items)
        
        let idsToDelete = [items[2].id, items[5].id]
        await cacheManager.deleteItems(ids: idsToDelete)
        try await sleepTask()
        
        #expect(cacheManager.cacheCount == 8)
        #expect(cacheManager.lastDocumentID == items.last?.id)
        #expect(await cacheManager.retrieveItems() == items.filter { !idsToDelete.contains($0.id) })
    }
    
    @Test func testRetrieveItems() async throws {
        let cacheManager = CacheManager<MockItem>()
        let items = MockItem.createItems(count: 10)
        await cacheManager.storeInitialData(items: items)
        
        #expect(await cacheManager.retrieveItems() == items)
        #expect(cacheManager.cacheCount == 10)
        #expect(cacheManager.lastDocumentID == items.last?.id)
    }
    
    @Test func testRetrieveItem() async throws {
        let cacheManager = CacheManager<MockItem>()
        let items = MockItem.createItems(count: 10)
        await cacheManager.storeInitialData(items: items)
        
        let retrievedItem = await cacheManager.retrieveItem(id: items[3].id)
        #expect(retrievedItem == items[3])
        #expect(cacheManager.cacheCount == 10)
        #expect(cacheManager.lastDocumentID == items.last?.id)
    }
    
    @Test func testClearCache() async throws {
        let cacheManager = CacheManager<MockItem>()
        let items = MockItem.createItems(count: 10)
        await cacheManager.storeInitialData(items: items)
        #expect(cacheManager.cacheCount == 10)
        
        await cacheManager.clearCache()
        #expect(cacheManager.cacheCount == 0)
    }
}
