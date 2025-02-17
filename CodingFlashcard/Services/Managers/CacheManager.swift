//
//  CacheManager.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

class CacheManager<Item: Firestorable> {
    private var cache = [String: Item]()
    private var keyOrder: [String] = [] // ID is the key
    
    var cacheLimit: Int = 30
    var lastUpdatedDate: Date = Date()
    
    var lastDocumentID: String? {
        keyOrder.last
    }
    
    init() {
    }
    
    var cacheCount: Int {
        cache.count
    }
    
    func storeInitialData(items: [Item]) async {
        if items.count <= cacheLimit {
            await setInitialData(items: items)
        } else {
            let itemsToStore = Array(items.prefix(cacheLimit))
            await setInitialData(items: itemsToStore)
        }
        lastUpdatedDate = Date()
    }
    
    private func setInitialData(items: [Item]) async {
        keyOrder = items.map(\.id)
        for item in items {
            cache[item.id] = item
        }
    }
    
    func storeNewItems(newItems: [Item]) async {
        let newKeys = newItems.map(\.id)
        
        for _ in newKeys {
            if keyOrder.count >= cacheLimit {
                if let oldestKey = keyOrder.popLast() {
                    cache.removeValue(forKey: oldestKey)
                }
            }
        }
        
        keyOrder.insert(contentsOf: newKeys, at: 0)
        for (key, item) in zip(newKeys, newItems) {
            cache[key] = item
        }
        lastUpdatedDate = Date()
    }
    
    func storeOldItems(oldItems: [Item]) async {
        let newKeys = oldItems.map(\.id)
        
        let limit = cacheLimit - keyOrder.count
        guard limit > 0 else { return }
        
        if oldItems.count < limit {
            keyOrder.append(contentsOf: newKeys)
            for (key, item) in zip(newKeys, oldItems) {
                cache[key] = item
            }
        } else {
            let limitKeys = newKeys.prefix(limit)
            keyOrder.append(contentsOf: limitKeys)
            for (key, item) in zip(limitKeys, oldItems.prefix(limit)) {
                cache[key] = item
            }
        }
    }
    
    func deleteItems(ids: [String]) async {
        keyOrder.removeAll { ids.contains($0) }
        for id in ids {
            cache.removeValue(forKey: id)
        }
    }
    
    func retrieveItems() async -> [Item] {
        keyOrder.compactMap { cache[$0] }
    }
    
    func retrieveItem(id: String) async -> Item? {
        cache[id]
    }
    
    func clearCache() async {
        cache.removeAll()
        keyOrder.removeAll()
    }
}
