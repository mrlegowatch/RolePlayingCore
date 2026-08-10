//
//  InventoryEntryTests.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("InventoryEntry Tests")
struct InventoryEntryTests {

    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let items: Items

    init() throws {
        let gameData = try GameData("TestItemsConfiguration", from: .module)
        items = gameData.items
    }

    // MARK: - Programmatic init

    @Test("Init defaults: quantity 1, not equipped, new UUID")
    func initDefaults() {
        let sword = items["Longsword"]!
        let entry = InventoryEntry(item: sword)
        #expect(entry.quantity == 1)
        #expect(entry.isEquipped == false)
        #expect(entry.item.name == "Longsword")
    }

    @Test("Init with all parameters stores provided values")
    func initAllParameters() {
        let dagger = items["Dagger"]!
        let fixedID = UUID()
        let entry = InventoryEntry(id: fixedID, item: dagger, quantity: 5, isEquipped: true)
        #expect(entry.id == fixedID)
        #expect(entry.quantity == 5)
        #expect(entry.isEquipped == true)
        #expect(entry.item.name == "Dagger")
    }

    @Test("Each init call produces a unique ID")
    func uniqueIDs() {
        let item = items["Longsword"]!
        let a = InventoryEntry(item: item)
        let b = InventoryEntry(item: item)
        #expect(a.id != b.id)
    }

    @Test("totalWeight scales item weight by quantity")
    func totalWeight() {
        let item = items["Longsword"]!
        let entry = InventoryEntry(item: item, quantity: 3)
        #expect(entry.totalWeight.value == item.weight.value * 3)
        #expect(entry.totalWeight.unit == item.weight.unit)
    }

    @Test("totalWeight for quantity 1 equals item weight")
    func totalWeightSingleItem() {
        let item = items["Dagger"]!
        let entry = InventoryEntry(item: item)
        #expect(entry.totalWeight.value == item.weight.value)
    }

    // MARK: - Decode

    @Test("Decode with defaults: quantity 1, not equipped")
    func decodeDefaults() throws {
        let json = #"{"name": "Dagger"}"#.data(using: .utf8)!
        let entry = try decoder.decode(InventoryEntry.self, from: json, configuration: items)
        #expect(entry.item.name == "Dagger")
        #expect(entry.quantity == 1)
        #expect(entry.isEquipped == false)
    }

    @Test("Decode with explicit quantity")
    func decodeWithQuantity() throws {
        let json = #"{"name": "Arrow", "quantity": 20}"#.data(using: .utf8)!
        let entry = try decoder.decode(InventoryEntry.self, from: json, configuration: items)
        #expect(entry.quantity == 20)
    }

    @Test("Decode with equipped flag set")
    func decodeEquipped() throws {
        let json = #"{"name": "Chain Mail", "equipped": true}"#.data(using: .utf8)!
        let entry = try decoder.decode(InventoryEntry.self, from: json, configuration: items)
        #expect(entry.isEquipped == true)
    }

    @Test("Decode throws for unknown item name")
    func decodeThrowsUnknownItem() {
        let json = #"{"name": "Unobtainium Sword"}"#.data(using: .utf8)!
        #expect(throws: (any Error).self) {
            _ = try decoder.decode(InventoryEntry.self, from: json, configuration: items)
        }
    }

    // MARK: - Encode

    @Test("Encode omits quantity when it is 1")
    func encodeOmitsDefaultQuantity() throws {
        let entry = InventoryEntry(item: items["Dagger"]!, quantity: 1)
        let data = try encoder.encode(entry, configuration: items)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(dict?["quantity"] == nil, "quantity=1 should be omitted")
    }

    @Test("Encode omits equipped when false")
    func encodeOmitsDefaultEquipped() throws {
        let entry = InventoryEntry(item: items["Dagger"]!, isEquipped: false)
        let data = try encoder.encode(entry, configuration: items)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(dict?["equipped"] == nil, "isEquipped=false should be omitted")
    }

    @Test("Encode includes quantity when greater than 1")
    func encodeIncludesQuantity() throws {
        let entry = InventoryEntry(item: items["Arrow"]!, quantity: 10)
        let data = try encoder.encode(entry, configuration: items)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(dict?["quantity"] as? Int == 10)
    }

    @Test("Encode includes equipped when true")
    func encodeIncludesEquipped() throws {
        let entry = InventoryEntry(item: items["Chain Mail"]!, isEquipped: true)
        let data = try encoder.encode(entry, configuration: items)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(dict?["equipped"] as? Bool == true)
    }

    @Test("Encode round-trip preserves item name, quantity, and equipped")
    func encodeRoundTrip() throws {
        let entry = InventoryEntry(item: items["Longsword"]!, quantity: 2, isEquipped: true)
        let data = try encoder.encode(entry, configuration: items)
        let decoded = try decoder.decode(InventoryEntry.self, from: data, configuration: items)
        #expect(decoded.item.name == entry.item.name)
        #expect(decoded.quantity == entry.quantity)
        #expect(decoded.isEquipped == entry.isEquipped)
    }
}
