//
//  GroupByID.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Utility functions to group items by ID of each item.

import Foundation

/// Function to group items by ID with optional ID.
func groupByID<Item, ID>(items: [Item], keyPath: KeyPath<Item, ID?>) -> [ID: [Item]] {
    var groupedItems: [ID: [Item]] = [:]

    for item in items {
        if let id = item[keyPath: keyPath] {
            groupedItems[id, default: []].append(item)
        }
    }
    return groupedItems
}

/// Function to group items by ID with required ID.
func groupByID<Item, ID>(items: [Item], keyPath: KeyPath<Item, ID>) -> [ID: [Item]] {
    var groupedItems: [ID: [Item]] = [:]

    for item in items {
        let id = item[keyPath: keyPath]
        groupedItems[id, default: []].append(item)
    }
    return groupedItems
}
