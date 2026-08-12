//
//  DisplayOrderedTests.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore

@Suite("DisplayOrdered Tests")
struct DisplayOrderedTests {

    // Minimal test fixtures
    struct Item: Named {
        let name: String
    }

    struct Collection: DisplayOrdered {
        typealias Element = Item
        var all: [Item]
        var displayOrder: [String]

        init(_ names: [String], displayOrder: [String] = []) {
            self.all = names.map { Item(name: $0) }
            self.displayOrder = displayOrder
        }
    }

    // MARK: - Empty collection

    @Test("Empty collection returns empty result")
    func emptyCollection() {
        let collection = Collection([])
        #expect(collection.allByDisplayOrder.isEmpty)
    }

    // MARK: - Empty displayOrder (alphabetical fallback)

    @Test("Empty displayOrder sorts all elements alphabetically")
    func emptyDisplayOrderSortsAlphabetically() {
        let collection = Collection(["Zebra", "Apple", "Mango"])
        let result = collection.allByDisplayOrder.map(\.name)
        #expect(result == ["Apple", "Mango", "Zebra"])
    }

    @Test("Single element with empty displayOrder returns that element")
    func singleElementEmptyDisplayOrder() {
        let collection = Collection(["Only"])
        #expect(collection.allByDisplayOrder.first?.name == "Only")
    }

    @Test("Already-sorted elements with empty displayOrder stay sorted")
    func alreadySortedNoDisplayOrder() {
        let collection = Collection(["Alpha", "Beta", "Gamma"])
        let result = collection.allByDisplayOrder.map(\.name)
        #expect(result == ["Alpha", "Beta", "Gamma"])
    }

    // MARK: - Full displayOrder coverage

    @Test("All elements in displayOrder respects that order")
    func allElementsInDisplayOrder() {
        let collection = Collection(["Rogue", "Fighter", "Cleric"],
                                    displayOrder: ["Cleric", "Fighter", "Rogue"])
        let result = collection.allByDisplayOrder.map(\.name)
        #expect(result == ["Cleric", "Fighter", "Rogue"])
    }

    @Test("displayOrder can reverse alphabetical order")
    func displayOrderReversesAlphabetical() {
        let collection = Collection(["Alpha", "Beta", "Gamma"],
                                    displayOrder: ["Gamma", "Beta", "Alpha"])
        let result = collection.allByDisplayOrder.map(\.name)
        #expect(result == ["Gamma", "Beta", "Alpha"])
    }

    // MARK: - Partial displayOrder

    @Test("Listed elements come before unlisted, unlisted sort alphabetically")
    func partialDisplayOrderListedFirst() {
        let collection = Collection(["Zebra", "Apple", "Beta", "Cleric"],
                                    displayOrder: ["Cleric", "Beta"])
        let result = collection.allByDisplayOrder.map(\.name)
        // Listed first in displayOrder order, then unlisted alphabetically
        #expect(result == ["Cleric", "Beta", "Apple", "Zebra"])
    }

    @Test("Multiple unlisted elements sort alphabetically after listed ones")
    func unlistedElementsSortAlphabetically() {
        let collection = Collection(["Wizard", "Ranger", "Paladin", "Fighter", "Druid"],
                                    displayOrder: ["Fighter"])
        let result = collection.allByDisplayOrder.map(\.name)
        #expect(result.first == "Fighter")
        #expect(result.dropFirst().map { $0 } == ["Druid", "Paladin", "Ranger", "Wizard"])
    }

    // MARK: - displayOrder names not matching any element

    @Test("displayOrder names that match no element are ignored")
    func displayOrderWithNonexistentNames() {
        let collection = Collection(["Beta", "Alpha"],
                                    displayOrder: ["Nonexistent", "AlsoMissing"])
        let result = collection.allByDisplayOrder.map(\.name)
        // No matches → alphabetical fallback
        #expect(result == ["Alpha", "Beta"])
    }

    @Test("displayOrder with mix of matching and nonexistent names")
    func displayOrderMixedMatchingAndMissing() {
        let collection = Collection(["Apple", "Cherry", "Banana"],
                                    displayOrder: ["Ghost", "Cherry", "Phantom"])
        let result = collection.allByDisplayOrder.map(\.name)
        // "Cherry" is listed; "Apple" and "Banana" sort after
        #expect(result == ["Cherry", "Apple", "Banana"])
    }
}
