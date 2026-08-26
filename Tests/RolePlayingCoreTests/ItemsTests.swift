//
//  ItemsTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("Items Tests")
struct ItemsTests {

    let gameData: GameData

    init() throws {
        gameData = try GameData("TestItemsConfiguration", from: .module)
    }

    @Test("Registry loads all item categories")
    func registryCounts() {
        let items = gameData.items
        #expect(items.weapons.count == 12)
        #expect(items.armors.count == 7)
        #expect(items.gear.count == 10)
        #expect(items.tools.count == 6)
        #expect(items.count == 35)
    }

    @Test("Lookup by exact name")
    func lookupByName() {
        let items = gameData.items
        #expect(items["Longsword"] != nil)
        #expect(items["Chain Mail"] != nil)
        #expect(items["Rope"] != nil)
        #expect(items["Thieves' Tools"] != nil)
        #expect(items["NoSuchItem"] == nil)
    }

    @Test("Lookup by plural name")
    func lookupByPlural() {
        let items = gameData.items
        // Plurals resolve to the same item
        #expect(items["Daggers"]?.name == "Dagger")
        #expect(items["Arrows"]?.name == "Arrow")
        #expect(items["Longswords"]?.name == "Longsword")
    }

    @Test("Weapon type resolution")
    func weaponType() {
        let weapon = gameData.items["Longsword"] as? Weapon
        #expect(weapon != nil)
        #expect(weapon?.category == .martial)
        #expect(weapon?.damage.type == .slashing)
        #expect(weapon?.properties.contains(.versatile) == true)
        #expect(weapon?.versatileDamage != nil)
    }

    @Test("Armor type resolution")
    func armorType() {
        let armor = gameData.items["Chain Mail"] as? Armor
        #expect(armor != nil)
        #expect(armor?.category == .heavy)
        #expect(armor?.baseAC == 16)
        #expect(armor?.dexterityModifierRule == .excluded)
        #expect(armor?.stealthDisadvantage == true)
        #expect(armor?.strengthRequirement == 13)
    }

    @Test("Shield type resolution")
    func shieldType() {
        let shield = gameData.items["Shield"] as? Armor
        #expect(shield != nil)
        #expect(shield?.category == .shield)
        #expect(shield?.baseAC == 2)
        #expect(shield?.dexterityModifierRule == .bonus)
    }

    @Test("Gear pack with contents")
    func packContents() {
        let pack = gameData.items["Dungeoneer's Pack"] as? Gear
        #expect(pack != nil)
        #expect(pack?.category == .pack)
        #expect(pack?.contents?.isEmpty == false)
    }

    @Test("Tool type resolution")
    func toolType() {
        let tool = gameData.items["Thieves' Tools"] as? Tool
        #expect(tool != nil)
        #expect(tool?.toolType == .thieves)
    }

    @Test("EquipmentEntry parsing - item by name")
    func equipmentEntryItem() {
        let entry = EquipmentEntry.parse("Longsword",
                                        items: gameData.items,
                                        currencies: gameData.currencies)
        if case .item(let item, let qty) = entry {
            #expect(item.name == "Longsword")
            #expect(qty == 1)
        } else {
            Issue.record("Expected .item entry, got \(entry)")
        }
    }

    @Test("EquipmentEntry parsing - quantity + plural name")
    func equipmentEntryQuantity() {
        let entry = EquipmentEntry.parse("2 Daggers",
                                        items: gameData.items,
                                        currencies: gameData.currencies)
        if case .item(let item, let qty) = entry {
            #expect(item.name == "Dagger")
            #expect(qty == 2)
        } else {
            Issue.record("Expected .item entry, got \(entry)")
        }
    }

    @Test("EquipmentEntry parsing - money")
    func equipmentEntryMoney() {
        let entry = EquipmentEntry.parse("15 GP",
                                        items: gameData.items,
                                        currencies: gameData.currencies)
        if case .money(let m) = entry {
            #expect(m.totalValue > 0)
        } else {
            Issue.record("Expected .money entry, got \(entry)")
        }
    }

    @Test("EquipmentEntry parsing - unresolved note")
    func equipmentEntryNote() {
        let entry = EquipmentEntry.parse("Any Tool",
                                        items: gameData.items,
                                        currencies: gameData.currencies)
        if case .note(let s) = entry {
            #expect(s == "Any Tool")
        } else {
            Issue.record("Expected .note entry, got \(entry)")
        }
    }

    @Test("Encode round-trip preserves all item counts")
    func encodeRoundTrip() throws {
        let original = gameData.items
        let encoder = JSONEncoder()
        let data = try encoder.encode(original, configuration: gameData)
        let decoded = try JSONDecoder().decode(Items.self, from: data, configuration: gameData)
        #expect(decoded.weapons.count == original.weapons.count)
        #expect(decoded.armors.count == original.armors.count)
        #expect(decoded.gear.count == original.gear.count)
        #expect(decoded.tools.count == original.tools.count)
        #expect(decoded.count == original.count)
    }
}
