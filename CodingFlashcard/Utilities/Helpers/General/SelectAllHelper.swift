//
//  SelectAllDeckHelperGeneric.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

struct SelectAllHelper {
    var selectionState: SelectionState = .selectAll
    var selectedParentItemIDs: Set<String> = []
    var selectedSubItemIDs: Set<String> = []
    var parentIDsWithSubIDs: [String: [String]] = [:]
    var parentItemIDs: Set<String> = []
    var subItemIDs: Set<String> = []
    
    mutating func loadInitialItems(parentIDsWithSubIDs: [String: [String]]) {
        self.parentIDsWithSubIDs = parentIDsWithSubIDs
        self.parentItemIDs = Set(parentIDsWithSubIDs.map { $0.0 })
        self.subItemIDs = Set(parentIDsWithSubIDs.flatMap { $0.1.map { $0 }})
        self.selectedParentItemIDs = parentItemIDs
        self.selectedSubItemIDs = subItemIDs
        selectAllItems()
    }
    
    // MARK: - Selection State Methods
    func isSelectAll() -> Bool {
        return selectionState == .selectAll
    }
    
    mutating func selectAllItems() {
        selectedParentItemIDs = parentItemIDs
        selectedSubItemIDs = subItemIDs
        selectionState = .selectAll
    }

    mutating func deselectAllItems() {
        selectedParentItemIDs = []
        selectedSubItemIDs = []
        selectionState = .deselectAll
    }
    
    mutating func toggleSelectAll() {
        switch selectionState {
        case .selectAll:
            deselectAllItems()
        case .deselectAll:
            selectAllItems()
        }
    }
    
    mutating func updateSelectionState() {
        if selectedParentItemIDs == parentItemIDs && selectedSubItemIDs == subItemIDs {
            selectionState = .selectAll
        } else {
            selectionState = .deselectAll
        }
    }
    
    // MARK: - Item State Methods
    func isParentItemSelected(for itemID: String) -> Bool {
        return selectedParentItemIDs.contains(itemID)
    }
    
    func isSubItemSelected(for itemID: String) -> Bool {
        return selectedSubItemIDs.contains(itemID)
    }
    
    mutating func toggleSelectedSubItem(itemID: String) {
        if selectedSubItemIDs.contains(itemID) {
            collapseSelectedSubItem(itemID: itemID)
        } else {
            expandSelectedSubItem(itemID: itemID)
        }
    }
    
    mutating func toggleSelectedParentItem(itemID: String) {
        if selectedParentItemIDs.contains(itemID) {
            collapseSelectedParentItem(itemID: itemID)
        } else {
            expandSelectedParentItem(itemID: itemID)
        }
    }
    
    private mutating func expandSelectedSubItem(itemID: String) {
        selectedSubItemIDs.insert(itemID)
        updateParentSelectionState(for: itemID)
        updateSelectionState()
    }
    
    private mutating func collapseSelectedSubItem(itemID: String) {
        selectedSubItemIDs.remove(itemID)
        updateParentSelectionState(for: itemID)
        updateSelectionState()
    }
    
    private mutating func expandSelectedParentItem(itemID: String) {
        selectedParentItemIDs.insert(itemID)
        updateSubItemSelectionState(for: itemID)
        updateSelectionState()
    }
    
    private mutating func collapseSelectedParentItem(itemID: String) {
        selectedParentItemIDs.remove(itemID)
        updateSubItemSelectionState(for: itemID)
        updateSelectionState()
    }
    
    private mutating func updateParentSelectionState(for subItemID: String) {
        guard let parentItemID = getParentItemID(for: subItemID) else { return }
        let subItemIDs = parentIDsWithSubIDs[parentItemID] ?? []
        if selectedSubItemIDs.isSuperset(of: subItemIDs) {
            selectedParentItemIDs.insert(parentItemID)
        } else {
            selectedParentItemIDs.remove(parentItemID)
        }
    }
    
    private mutating func updateSubItemSelectionState(for parentItemID: String) {
        let subdeckIDs = parentIDsWithSubIDs[parentItemID] ?? []
        if selectedParentItemIDs.contains(parentItemID) {
            selectedSubItemIDs.formUnion(subdeckIDs)
        } else {
            selectedSubItemIDs.subtract(subdeckIDs)
        }
    }
    
    private func getParentItemID(for subItemID: String) -> String? {
        for (parentID, subItemIDs) in parentIDsWithSubIDs {
            if subItemIDs.contains(where: { $0 == subItemID }) {
                return parentID
            }
        }
        return nil
    }
}
