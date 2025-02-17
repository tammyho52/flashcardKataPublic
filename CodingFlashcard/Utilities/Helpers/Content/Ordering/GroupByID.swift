//
//  GroupByID.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

func groupByID<Item, ID>(items: [Item], keyPath: KeyPath<Item, ID?>) -> [ID: [Item]] {
    var groupedItems: [ID: [Item]] = [:]
    
    for item in items {
        if let id = item[keyPath: keyPath] {
            groupedItems[id, default: []].append(item)
        }
    }
    return groupedItems
}

func groupByID<Item, ID>(items: [Item], keyPath: KeyPath<Item, ID>) -> [ID: [Item]] {
    var groupedItems: [ID: [Item]] = [:]
    
    for item in items {
        let id = item[keyPath: keyPath]
        groupedItems[id, default: []].append(item)
    }
    return groupedItems
}
