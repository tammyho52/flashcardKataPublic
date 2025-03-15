//
//  GroupByID.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Utility functions to group items by ID of each item.

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
