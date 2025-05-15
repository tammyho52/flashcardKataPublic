//
//  CacheManager.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This class manages a cache for items conforming to the `Firestorable`
//  protocol, providing efficient storage and retrieval.

import Foundation

/// A generic cache manager for items conforming to the `Firestorable` protocol.
@MainActor
class CacheManager<Item: Firestorable> {
    // MARK: - Properties
    private var cache = [String: Item]()
    private var keyOrder: [String] = [] // The order of keys for cache eviction

    var cacheLimit: Int = ContentConstants.cacheLimit // The maximum number of items that can be stored in the cache
    var lastUpdatedDate: Date = Date()

    var lastDocumentID: String? {
        keyOrder.last
    }

    var cacheCount: Int {
        cache.count
    }

    /// Initializes the cache manager with items meeting a specified cache limit.
    func storeInitialData(items: [Item]) async {
        if items.count <= cacheLimit {
            await setInitialData(items: items)
        } else {
            let itemsToStore = Array(items.prefix(cacheLimit))
            await setInitialData(items: itemsToStore)
        }
        lastUpdatedDate = Date()
    }

    /// Sets the initial data in the cache and updates the key order.
    private func setInitialData(items: [Item]) async {
        keyOrder = items.map(\.id)
        for item in items {
            cache[item.id] = item
        }
    }

    /// Updates the cache with new items and removes old items if necessary.
    func storeNewItems(newItems: [Item]) async {
        let newKeys = newItems.map(\.id)
        
        // Remove existing items from the cache if they are being updated
        keyOrder.removeAll { newKeys.contains($0) }
        
        // Check if the cache limit is exceeded and remove the oldest items
        let totalKeys = keyOrder.count + newKeys.count
        if totalKeys >= cacheLimit {
            for _ in 0..<(totalKeys - cacheLimit) {
                if let oldestKey = keyOrder.popLast() {
                    cache.removeValue(forKey: oldestKey)
                }
            }
        }
        
        // Insert new items at the beginning of the key order
        keyOrder.insert(contentsOf: newKeys, at: 0)
        for (key, item) in zip(newKeys, newItems) {
            cache[key] = item
        }
        
        // Update the last updated date
        lastUpdatedDate = Date()
    }

    /// Stores old items in the cache, ensuring that the cache limit is respected.
    func storeOldItems(oldItems: [Item]) async {
        let filteredItems = oldItems.filter { !keyOrder.contains($0.id) }
        
        // Check if the cache limit is exceeded and return if so
        let remainingLimit = cacheLimit - keyOrder.count
        guard remainingLimit > 0 else { return }
        
        // Store only the number of items that fit within the cache limit
        let itemsToStore = Array(filteredItems.prefix(remainingLimit))
        let keysToStore = itemsToStore.map(\.id)
        keyOrder.append(contentsOf: keysToStore)
        for (key, item) in zip(keysToStore, itemsToStore) {
            cache[key] = item
        }
    }

    /// Deletes items from the cache based on their IDs.
    func deleteItems(ids: [String]) async {
        keyOrder.removeAll { ids.contains($0) }
        for id in ids {
            cache.removeValue(forKey: id)
        }
    }

    /// Retrieves items from the cache based on their IDs.
    func retrieveItems() async -> [Item] {
        keyOrder.compactMap { cache[$0] }
    }

    /// Retrieves a specific item from the cache based on its ID.
    func retrieveItem(id: String) async -> Item? {
        cache[id]
    }

    /// Clears the cache by removing all items and resetting the key order.
    func clearCache() async {
        cache.removeAll()
        keyOrder.removeAll()
    }
}
