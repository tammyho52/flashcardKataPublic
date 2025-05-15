//
//  SelectAllHelperTests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import Testing
import XCTest

struct SelectAllHelperTests {

    @Test func testInitialState() async throws {
        var helper = SelectAllHelper()
        let items = Deck.sampleParentDeckWithSubDecksIDDictionary
        helper.loadInitialItems(parentIDsWithSubIDs: items)
        
        #expect(helper.isSelectAll() == true)
        #expect(helper.selectedParentItemIDs == Set(items.keys))
        #expect(helper.selectedSubItemIDs == Set(items.values.flatMap { $0 }))
        #expect(helper.parentIDsWithSubIDs == items)
        #expect(helper.parentItemIDs == Set(items.keys))
        #expect(helper.subItemIDs == Set(items.values.flatMap { $0 }))
    }
    
    @Test func testToggleSelectAll() async throws {
        var helper = SelectAllHelper()
        let items = Deck.sampleParentDeckWithSubDecksIDDictionary
        helper.loadInitialItems(parentIDsWithSubIDs: items)
        
        // Deselect all items
        helper.toggleSelectAll()
        #expect(helper.isSelectAll() == false)
        #expect(helper.selectedParentItemIDs.isEmpty)
        #expect(helper.selectedSubItemIDs.isEmpty)
        
        // Select all items
        helper.toggleSelectAll()
        #expect(helper.isSelectAll() == true)
        #expect(helper.selectedParentItemIDs == Set(items.keys))
        #expect(helper.selectedSubItemIDs == Set(items.values.flatMap { $0 }))
    }
    
    @Test func testUpdateSelectionState() async throws {
        var helper = SelectAllHelper()
        let items = Deck.sampleParentDeckWithSubDecksIDDictionary
        helper.loadInitialItems(parentIDsWithSubIDs: items)
        
        // Selection State should be deselectAll
        helper.selectedParentItemIDs.remove(items.keys.first!)
        helper.selectedSubItemIDs.subtract(items.values.first!)
        helper.updateSelectionState()
        #expect(helper.isSelectAll() == false)
        
        // Selection State should be selectAll
        helper.selectedParentItemIDs.insert(items.keys.first!)
        helper.selectedSubItemIDs.formUnion(items.values.first!)
        helper.updateSelectionState()
        #expect(helper.isSelectAll() == true)
    }
    
    @Test func testIsParentItemSelected() async throws {
        var helper = SelectAllHelper()
        let items = Deck.sampleParentDeckWithSubDecksIDDictionary
        helper.loadInitialItems(parentIDsWithSubIDs: items)
        
        // Test with an existing parent item ID
        let parentItemID = items.keys.first!
        #expect(helper.isParentItemSelected(for: parentItemID) == true)
        
        helper.selectedParentItemIDs.remove(parentItemID)
        #expect(helper.isParentItemSelected(for: parentItemID) == false)
        
        // Test with a non-existing parent item ID
        let nonExistingParentItemID = "nonExistingParentID"
        #expect(helper.isParentItemSelected(for: nonExistingParentItemID) == false)
    }
    
    @Test func testIsSubItemSelected() async throws {
        var helper = SelectAllHelper()
        let items = Deck.sampleParentDeckWithSubDecksIDDictionary
        helper.loadInitialItems(parentIDsWithSubIDs: items)
        
        // Test with an existing sub item ID
        let subItemID = items.values.first!.first!
        #expect(helper.isSubItemSelected(for: subItemID) == true)
        
        helper.selectedSubItemIDs.remove(subItemID)
        #expect(helper.isSubItemSelected(for: subItemID) == false)
        
        // Test with a non-existing sub item ID
        let nonExistingSubItemID = "nonExistingSubID"
        #expect(helper.isSubItemSelected(for: nonExistingSubItemID) == false)
    }
    
    @Test func testToggleSelectedSubItem() async throws {
        var helper = SelectAllHelper()
        let items = Deck.sampleParentDeckWithSubDecksIDDictionary
        helper.loadInitialItems(parentIDsWithSubIDs: items)
        
        // Test collapsing an existing sub item
        let subItemID = items.values.first!.first!
        helper.toggleSelectedSubItem(itemID: subItemID)
        #expect(helper.selectedSubItemIDs.contains(subItemID) == false)
        
        // Test expanding an existing sub item
        helper.toggleSelectedSubItem(itemID: subItemID)
        #expect(helper.selectedSubItemIDs.contains(subItemID) == true)
        
        // Test expanding and collapsing a non-existing sub item
        helper.toggleSelectedSubItem(itemID: "nonExistingSubID")
        #expect(helper.selectedSubItemIDs.contains("nonExistingSubID") == false)
    }
    
    @Test func testToggleSelectedParentItem() async throws {
        var helper = SelectAllHelper()
        let items = Deck.sampleParentDeckWithSubDecksIDDictionary
        helper.loadInitialItems(parentIDsWithSubIDs: items)
        
        // Test collapsing an existing sub item
        let parentItemID = items.keys.first!
        helper.toggleSelectedParentItem(itemID: parentItemID)
        #expect(helper.selectedParentItemIDs.contains(parentItemID) == false)
        
        // Test expanding an existing sub item
        helper.toggleSelectedParentItem(itemID: parentItemID)
        #expect(helper.selectedParentItemIDs.contains(parentItemID) == true)
        
        // Test expanding and collapsing a non-existing sub item
        helper.toggleSelectedParentItem(itemID: "nonExistingSubID")
        #expect(helper.selectedParentItemIDs.contains("nonExistingSubID") == false)
    }
}

// Performance tests using XCTest
class SelectAllHelperPerformanceTests: XCTestCase {
    func testPerformanceToggleSelectAll() {
        var helper = SelectAllHelper()
        let largeItemCount = 1000
        var largeItems: [String: [String]] = [:]
        
        for i in 0..<largeItemCount {
            let parentID = "Parent\(i)"
            let subItemIDs: [String] = (0..<10).map { "Parent\(i)SubItem\($0)" }
            largeItems[parentID] = subItemIDs
        }
        helper.loadInitialItems(parentIDsWithSubIDs: largeItems)
        XCTAssertEqual(helper.selectedParentItemIDs.count, largeItemCount)
        XCTAssertEqual(helper.selectedSubItemIDs.count, largeItemCount * 10)
        
        measure {
            helper.toggleSelectAll()
        }
        XCTAssertEqual(helper.parentItemIDs.count, largeItemCount)
        XCTAssertEqual(helper.subItemIDs.count, largeItemCount * 10)
        XCTAssertEqual(helper.parentIDsWithSubIDs, largeItems)
    }
}
