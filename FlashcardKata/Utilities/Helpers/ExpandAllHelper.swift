//
//  ExpandAllHelper.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Helper structure to manage the expansion and collase state of items in a list.

import Foundation

struct ExpandAllHelper {
    // MARK: - Properties
    var expansionState: ExpansionState = .expandAll
    var expandedItemIDs: Set<String> = []
    var itemIDs: Set<String> = []

    mutating func loadInitialItems(itemIDs: [String]) {
        self.itemIDs = Set(itemIDs)
        expandAllItems()
    }

    // MARK: - Expansion State Methods
    func isExpandAll() -> Bool {
        return expansionState == .expandAll
    }

    mutating func toggleExpandAll() {
        if expansionState == .expandAll {
            collapseAllItems()
        } else {
            expandAllItems()
        }
    }

    private mutating func expandAllItems() {
        expandedItemIDs = itemIDs
        expansionState = .expandAll
    }

    private mutating func collapseAllItems() {
        expandedItemIDs = []
        expansionState = .collapseAll
    }

    // MARK: - Item State Methods
    func isExpanded(for itemID: String) -> Bool {
        guard itemIDs.contains(itemID) else {
            reportItemNotFoundError(itemID)
            return expansionState == .expandAll ? true : false
        }
        return expandedItemIDs.contains(itemID)
    }

    mutating func expand(for itemID: String) {
        guard itemIDs.contains(itemID) else {
            reportItemNotFoundError(itemID)
            return
        }
        expandedItemIDs.insert(itemID)
        checkForExpandAllExpansionState()
    }

    mutating func collapse(for itemID: String) {
        guard itemIDs.contains(itemID) else {
            reportItemNotFoundError(itemID)
            return
        }
        expandedItemIDs.remove(itemID)
        checkForCollapseExpansionState()
    }
    
    // MARK: - Private Methods
    private mutating func checkForCollapseExpansionState() {
        guard expansionState == .expandAll else { return }
        expansionState = .collapseAll
    }

    private mutating func checkForExpandAllExpansionState() {
        guard expansionState == .collapseAll else { return }
        if expandedItemIDs == itemIDs {
            expansionState = .expandAll
        }
    }
    
    private func reportItemNotFoundError(_ itemID: String) {
        reportError(
            NSError(
                domain: "ExpandAllHelper",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Item ID \(itemID) not found in itemIDs"]
            )
        )
    }
}
