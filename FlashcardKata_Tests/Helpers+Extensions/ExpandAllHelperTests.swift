//
//  ExpandAllHelperTests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import Testing

struct ExpandAllHelperTests {

    @Test func testInitialState() async throws {
        var helper = ExpandAllHelper()
        let itemIDs = MockItem.createItems(count: 5).map { $0.id }
        helper.loadInitialItems(itemIDs: itemIDs)
        
        #expect(helper.isExpandAll() == true)
        #expect(helper.expandedItemIDs == Set(itemIDs))
        #expect(helper.itemIDs == Set(itemIDs))
    }
    
    @Test func testToggleExpandAll() async throws {
        var helper = ExpandAllHelper()
        let itemIDs = MockItem.createItems(count: 5).map { $0.id }
        helper.loadInitialItems(itemIDs: itemIDs)
        
        // Toggles to collapse all
        helper.toggleExpandAll()
        #expect(helper.isExpandAll() == false)
        #expect(helper.expandedItemIDs == [])
        #expect(helper.itemIDs == Set(itemIDs))
        
        // Toggles back to expand all
        helper.toggleExpandAll()
        #expect(helper.isExpandAll() == true)
        #expect(helper.expandedItemIDs == Set(itemIDs))
        #expect(helper.itemIDs == Set(itemIDs))
    }
    
    @Test func testIsExpanded() async throws {
        var helper = ExpandAllHelper()
        let itemIDs = MockItem.createItems(count: 5).map { $0.id }
        helper.loadInitialItems(itemIDs: itemIDs)
        
        #expect(helper.isExpanded(for: itemIDs[0]) == true)
        #expect(helper.isExpanded(for: itemIDs[1]) == true)
        
        helper.collapse(for: itemIDs[0])
        #expect(helper.isExpanded(for: itemIDs[0]) == false)
        #expect(helper.isExpanded(for: itemIDs[1]) == true)
    }
    
    @Test func testExpandAndCollapseItem() async throws {
        var helper = ExpandAllHelper()
        let itemIDs = MockItem.createItems(count: 5).map { $0.id }
        helper.loadInitialItems(itemIDs: itemIDs)
        
        // Collapsing an item
        helper.collapse(for: itemIDs[0])
        #expect(helper.isExpanded(for: itemIDs[0]) == false)
        #expect(helper.isExpanded(for: itemIDs[1]) == true)
        
        // Expanding an item
        helper.expand(for: itemIDs[0])
        #expect(helper.isExpanded(for: itemIDs[0]) == true)
        #expect(helper.isExpanded(for: itemIDs[1]) == true)
        #expect(helper.expandedItemIDs == Set(itemIDs))
    }
}

//
//struct ExpandAllHelper {
//    var expansionState: ExpansionState = .expandAll
//    var expandedItemIDs: Set<String> = []
//    var itemIDs: Set<String> = []
//
//    mutating func loadInitialItems(itemIDs: [String]) {
//        self.itemIDs = Set(itemIDs)
//        expandAllItems()
//    }
//
//    // MARK: - Expansion State Methods
//    func isExpandAll() -> Bool {
//        return expansionState == .expandAll
//    }
//
//    mutating func toggleExpandAll() {
//        if expansionState == .expandAll {
//            collapseAllItems()
//        } else {
//            expandAllItems()
//        }
//    }
//
//    mutating func expandAllItems() {
//        expandedItemIDs = itemIDs
//        expansionState = .expandAll
//    }
//
//    mutating func collapseAllItems() {
//        expandedItemIDs = []
//        expansionState = .collapseAll
//    }
//
//    // MARK: - Item State Methods
//    func isExpanded(for itemID: String) -> Bool {
//        guard itemIDs.contains(itemID) else { return expansionState == .expandAll ? true : false }
//        return expandedItemIDs.contains(itemID)
//    }
//
//    private mutating func checkForCollapseExpansionState() {
//        guard expansionState == .expandAll else { return }
//        expansionState = .collapseAll
//    }
//
//    private mutating func checkForExpandAllExpansionState() {
//        guard expansionState == .collapseAll else { return }
//        if expandedItemIDs == itemIDs {
//            expansionState = .expandAll
//        }
//    }
//
//    mutating func expand(for itemID: String) {
//        guard itemIDs.contains(itemID) else { return }
//        expandedItemIDs.insert(itemID)
//        checkForExpandAllExpansionState()
//    }
//
//    mutating func collapse(for itemID: String) {
//        guard itemIDs.contains(itemID) else { return }
//        expandedItemIDs.remove(itemID)
//        checkForCollapseExpansionState()
//    }
//}
